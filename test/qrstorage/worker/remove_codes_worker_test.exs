defmodule QrstorageRemoveCodesWorkerTest do
  use Qrstorage.DataCase
  use Qrstorage.StorageCase
  use Oban.Testing, repo: Qrstorage.Repo

  alias Qrstorage.QrCodes.QrCode
  alias Qrstorage.QrCodes
  alias Qrstorage.Repo

  describe "perform" do
    @valid_attrs %{
      delete_after: ~D[2010-04-17],
      text: "some text",
      hide_text: false,
      content_type: "text",
      language: nil,
      deltas: %{"id" => "test"},
      dots_type: "dots"
    }

    @valid_tts_attrs %{
      delete_after: ~D[2010-04-17],
      text: "text",
      content_type: "audio",
      language: "de",
      dots_type: "dots",
      voice: "female"
    }

    @valid_recording_attrs %{
      delete_after: ~D[2010-04-17],
      text: "a",
      content_type: "recording",
      dots_type: "dots"
    }

    def qr_code_fixture(attrs \\ %{}) do
      {:ok, qr_code} =
        attrs
        |> Enum.into(@valid_attrs)
        |> QrCodes.create_qr_code()

      qr_code
    end

    def infinity_qr_code() do
      attrs = %{@valid_attrs | delete_after: Timex.end_of_year(QrCode.max_delete_after_year())}
      qr_code_fixture(attrs)
    end

    def overdue_qr_code(input_attrs \\ @valid_attrs) do
      attrs = %{input_attrs | delete_after: Timex.shift(Timex.now(), months: -5)}
      qr_code_fixture(attrs)
    end

    def active_qr_code() do
      attrs = %{@valid_attrs | delete_after: Timex.shift(Timex.now(), months: 5)}
      qr_code_fixture(attrs)
    end

    test "perform/1 deletes qr codes with a delete_after date older than now" do
      infinity_qr_code = infinity_qr_code()
      overdue_qr_code = overdue_qr_code()
      active_qr_code = active_qr_code()

      assert :ok = perform_job(Qrstorage.Worker.RemoveCodesWorker, %{})

      # only the overdue qr code is deleted:
      assert Repo.get(QrCode, infinity_qr_code.id) != nil
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
