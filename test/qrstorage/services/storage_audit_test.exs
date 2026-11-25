defmodule Qrstorage.Services.StorageAuditTest do
  use Qrstorage.DataCase
  use Qrstorage.StorageCase

  alias Qrstorage.Services.StorageAudit

  @old DateTime.add(DateTime.utc_now(), -3, :day)

  defp mock_listing(objects) do
    Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock
    |> expect(:list_objects, fn _bucket, "audio/" -> {:ok, objects} end)
  end

  setup do
    System.put_env("OBJECT_STORAGE_BUCKET", "bucket")
    :ok
  end

  test "reports files without qr code, with wrong type, unrecognized keys and skips recent files" do
    tts = qr_code_fixture(%{content_type: "audio", language: "de", voice: "female", text: "hi"})
    orphan_id = Ecto.UUID.generate()
    recent_id = Ecto.UUID.generate()

    mock_listing([
      %{key: "audio/tts/#{tts.id}.mp3", last_modified: @old},
      %{key: "audio/recording/#{tts.id}.webm", last_modified: @old},
      %{key: "audio/recording/#{orphan_id}.webm", last_modified: @old},
      %{key: "audio/tts/#{recent_id}.mp3", last_modified: DateTime.utc_now()},
      %{key: "audio/garbage.txt", last_modified: @old}
    ])

    assert {:ok, report} = StorageAudit.find_orphans()
    assert report.checked == 3
    assert report.skipped_recent == 1
    assert report.unrecognized == ["audio/garbage.txt"]
    assert report.orphans == Enum.sort(["audio/recording/#{tts.id}.webm", "audio/recording/#{orphan_id}.webm"])
  end

  test "returns no orphans when everything matches" do
    tts = qr_code_fixture(%{content_type: "audio", language: "de", voice: "female", text: "hi"})
    mock_listing([%{key: "audio/tts/#{tts.id}.mp3", last_modified: @old}])

    assert {:ok, %{orphans: [], checked: 1}} = StorageAudit.find_orphans()
  end

  test "passes on storage errors" do
    Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock
    |> expect(:list_objects, fn _, _ -> {:error, :boom} end)

    assert {:error, :boom} = StorageAudit.find_orphans()
  end
end
