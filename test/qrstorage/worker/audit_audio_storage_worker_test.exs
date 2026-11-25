defmodule Qrstorage.Worker.AuditAudioStorageWorkerTest do
  use Qrstorage.DataCase
  use Qrstorage.StorageCase
  use Oban.Testing, repo: Qrstorage.Repo

  import ExUnit.CaptureLog

  alias Qrstorage.Worker.AuditAudioStorageWorker

  @old DateTime.add(DateTime.utc_now(), -3, :day)

  setup do
    System.put_env("OBJECT_STORAGE_BUCKET", "bucket")
    Logger.configure(level: :info)
    on_exit(fn -> Logger.configure(level: :warning) end)
    :ok
  end

  defp mock_listing(objects) do
    Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock
    |> expect(:list_objects, fn _bucket, "audio/" -> {:ok, objects} end)
  end

  test "perform/1 logs a warning with orphaned files" do
    orphan_id = Ecto.UUID.generate()
    mock_listing([%{key: "audio/tts/#{orphan_id}.mp3", last_modified: @old}])

    log = capture_log(fn -> assert :ok = perform_job(AuditAudioStorageWorker, %{}) end)

    assert log =~ "[warning]"
    assert log =~ "audio/tts/#{orphan_id}.mp3"
  end

  test "perform/1 logs info when everything matches" do
    tts = qr_code_fixture(%{content_type: "audio", language: "de", voice: "female", text: "hi"})
    mock_listing([%{key: "audio/tts/#{tts.id}.mp3", last_modified: @old}])

    log = capture_log(fn -> assert :ok = perform_job(AuditAudioStorageWorker, %{}) end)

    refute log =~ "[warning]"
    assert log =~ "orphaned files:  0"
  end

  test "perform/1 returns an error when the storage can't be listed" do
    Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock
    |> expect(:list_objects, fn _, _ -> {:error, :boom} end)

    capture_log(fn -> assert {:error, :boom} = perform_job(AuditAudioStorageWorker, %{}) end)
  end
end
