defmodule Qrstorage.Services.StorageAudit do
  @moduledoc """
  Read-only consistency check between the audio files in the object storage and the qr codes in the database.
  Finds audio files (recordings and tts) that have no matching qr code.
  """
  import Ecto.Query, warn: false

  alias Qrstorage.QrCodes.QrCode
  alias Qrstorage.Repo
  alias Qrstorage.Services.StorageService

  @key_regex ~r|\Aaudio/(recording\|tts)/([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})\.(webm\|mp3)\z|
  @batch_size 500

  @doc """
  Returns `{:ok, report}` where report contains:
    * `:checked` - number of audio files compared with the database
    * `:orphans` - keys without a qr code (or whose qr code has a different content type)
    * `:unrecognized` - keys that don't follow the `audio/<type>/<uuid>.<ext>` scheme
    * `:skipped_recent` - files younger than `grace_minutes`, ignored because an upload or deletion could be in flight
  """
  def find_orphans(grace_minutes \\ 60) do
    with {:ok, objects} <- StorageService.list_audio_objects() do
      {:ok, build_report(objects, grace_minutes)}
    end
  end

  def format_report(report) do
    """
    Audio storage audit
      checked files:   #{report.checked}
      skipped (recent): #{report.skipped_recent}
      orphaned files:  #{length(report.orphans)}
      unrecognized:    #{length(report.unrecognized)}
    #{format_keys("Orphaned files", report.orphans)}#{format_keys("Unrecognized keys", report.unrecognized)}\
    """
  end

  defp format_keys(_title, []), do: ""
  defp format_keys(title, keys), do: "\n#{title}:\n" <> Enum.map_join(keys, "\n", &"  #{&1}") <> "\n"

  defp build_report(objects, grace_minutes) do
    cutoff = DateTime.add(DateTime.utc_now(), -grace_minutes * 60, :second)
    {recent, old} = Enum.split_with(objects, &recent?(&1, cutoff))

    {parsed, unrecognized} =
      old
      |> Enum.reject(&String.ends_with?(&1.key, "/"))
      |> Enum.map(&parse_key/1)
      |> Enum.split_with(&match?({:ok, _, _, _}, &1))

    orphans =
      parsed
      |> Enum.map(fn {:ok, key, folder, id} -> {key, folder, id} end)
      |> Enum.chunk_every(@batch_size)
      |> Enum.flat_map(&orphans_in_batch/1)

    %{
      checked: length(parsed),
      orphans: Enum.sort(orphans),
      unrecognized: unrecognized |> Enum.map(fn {:error, key} -> key end) |> Enum.sort(),
      skipped_recent: length(recent)
    }
  end

  # a missing last_modified is treated as old, so that such files are never silently skipped:
  defp recent?(%{last_modified: %DateTime{} = last_modified}, cutoff),
    do: DateTime.compare(last_modified, cutoff) == :gt

  defp recent?(_object, _cutoff), do: false

  defp parse_key(%{key: key}) do
    case Regex.run(@key_regex, key) do
      [_, folder, id, _ext] -> {:ok, key, folder, String.downcase(id)}
      _ -> {:error, key}
    end
  end

  defp orphans_in_batch(batch) do
    ids = Enum.map(batch, fn {_key, _folder, id} -> id end)

    content_types =
      Repo.all(from q in QrCode, where: q.id in ^ids, select: {q.id, q.content_type})
      |> Map.new()

    for {key, folder, id} <- batch, content_types[id] != expected_content_type(folder), do: key
  end

  defp expected_content_type("recording"), do: :recording
  defp expected_content_type("tts"), do: :audio
end
