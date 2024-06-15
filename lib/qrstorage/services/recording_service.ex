defmodule Qrstorage.Services.RecordingService do
  require Logger

  import QrstorageWeb.Gettext

  def extract_recording_from_params(params) do
    if Map.has_key?(params, "audio_file") do
      extract_recording_from_plug_upload(params["audio_file"])
    else
      :error
    end
  end

  # We get the path from %Plug.Upload{}, which is fine:
  # sobelow_skip ["Traversal"]
  defp extract_recording_from_plug_upload(%Plug.Upload{} = upload) do
    if upload.content_type == "audio/mp3" do
      case File.read(upload.path) do
        {:ok, audio_file} ->
          {:ok, audio_file, upload.content_type}

        {:error, _} ->
          Logger.error("Error while extracting audio file from plug")
          {:error, gettext("Error while extracting audio file from plug.")}
      end
    else
      Logger.error(
        "Error while extracting audio file from plug: Tried to upload different audio format: #{upload.content_type}"
      )

      {:error, gettext("Error while extracting audio file from plug: Invalid content type")}
    end
  end

  defp extract_recording_from_plug_upload(_) do
    Logger.error("Error while extracting audio file from plug, plug not found in params")
    {:error, gettext("Error while extracting audio file from plug.")}
  end
end
