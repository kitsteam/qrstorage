defmodule QrstorageRemoveCodesWorkerTest do
  use Qrstorage.DataCase
  use Qrstorage.StorageCase
  use Oban.Testing, repo: Qrstorage.Repo

  alias Qrstorage.QrCodes.QrCode
  alias Qrstorage.QrCodes
  alias Qrstorage.Repo

  describe "perform" do
    @valid_tts_attrs %{
      delete_after_months: 1,
      text: "text",
      content_type: "audio",
      language: "de",
      dots_type: "dots",
      voice: "female"
    }

    @valid_recording_attrs %{
      delete_after_months: 1,
      text: "a",
      content_type: "recording",
      dots_type: "dots"
    }

    test "perform/1 deletes qr codes with a delete_after_months date older than now" do
      overdue_qr_code = overdue_qr_code()
      active_qr_code = qr_code_fixture()

      assert :ok = perform_job(Qrstorage.Worker.RemoveCodesWorker, %{})

      # only the overdue qr code is deleted:
      assert Repo.get(QrCode, overdue_qr_code.id) == nil
      assert Repo.get(QrCode, active_qr_code.id) != nil
    end

    test "perform/1 deletes tts files from object storage when code is deleted" do
      overdue_tts_code = overdue_qr_code(@valid_tts_attrs)
      mockStorageServiceDeleteAllSuccess([overdue_tts_code.id], ["audio/tts/#{overdue_tts_code.id}.mp3"])

      assert :ok = perform_job(Qrstorage.Worker.RemoveCodesWorker, %{})

      assert Repo.get(QrCode, overdue_tts_code.id) == nil
    end

    test "perform/1 deletes recording files from object storage when code is deleted" do
      overdue_recording_code = overdue_qr_code(@valid_recording_attrs)

      mockStorageServiceDeleteAllSuccess([overdue_recording_code.id], [
        "audio/recording/#{overdue_recording_code.id}.mp3"
      ])

      assert :ok = perform_job(Qrstorage.Worker.RemoveCodesWorker, %{})

      assert Repo.get(QrCode, overdue_recording_code.id) == nil
    end

    test "perform/1 does not attempt to delete files from object storage when text code is deleted" do
      overdue_qr_code = overdue_qr_code()

      assert :ok = perform_job(Qrstorage.Worker.RemoveCodesWorker, %{})

      assert Repo.get(QrCode, overdue_qr_code.id) == nil
    end
  end
end
