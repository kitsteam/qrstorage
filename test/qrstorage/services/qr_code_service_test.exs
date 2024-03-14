defmodule Qrstorage.Services.QrCodeServiceTest do
  use Qrstorage.DataCase
  use Qrstorage.TtsCase
  use Qrstorage.StorageCase

  alias Qrstorage.Services.QrCodeService

  import ExUnit.CaptureLog

  @create_attrs %{
    "delete_after" => "10",
    "text" => "some text",
    "deltas" => "{\"ops\":[{\"insert\":\"Assad\\n\"}]}",
    "language" => nil,
    "content_type" => "text",
    "dots_type" => "dots",
    "voice" => nil,
    "hp" => nil
  }

  @tts_attrs %{
    "delete_after" => "10",
    "text" => "some text",
    "content_type" => "audio",
    "voice" => "female",
    "language" => "de",
    "dots_type" => "dots",
    "hp" => nil
  }

  @recording_attrs %{
    "delete_after" => "10",
    "text" => "a",
    "content_type" => "recording",
    "dots_type" => "dots",
    "hp" => nil,
    "audio_file" => nil
  }

  describe "create_qr_code/1" do
    test "create_qr_code/1 returns :ok when the code has been created successfully" do
      {:ok, qr_code} = QrCodeService.create_qr_code(@create_attrs)
      assert qr_code.text == "some text"
    end

    test "create_qrcode/1 returns :error, when the qr code cannot be created" do
      invalid_attrs = %{@create_attrs | "text" => ""}

      {:error, changeset} = QrCodeService.create_qr_code(invalid_attrs)
      assert "can't be blank" in errors_on(changeset).text
    end
  end

  describe "create_qr_code/1 for tts codes" do
    test "create_qr_code/1 returns :ok for tts codes" do
      mock_file_content = mockTtsServiceSuccess()
      mockStorageServicePutObjectSuccess(mock_file_content)
      {:ok, qr_code} = QrCodeService.create_qr_code(@tts_attrs)
      assert qr_code.text == "some text"
    end

    test "create_qr_code/1 deletes a qr_code when the tts file could not be retrieved from API" do
      mockTtsServiceError()
      qr_code_count_start = qr_code_count()

      {{status, _changeset, _message}, logs} =
        with_log(fn ->
          QrCodeService.create_qr_code(@tts_attrs)
        end)

      qr_code_count_end = qr_code_count()
      assert status == :error

      assert logs =~ "deleting qr code after creation"
      assert qr_code_count_start == qr_code_count_end
    end

    test "create_qr_code/1 deletes a qr_code when the text could not be translated by API" do
      mockLanguageServiceError()
      qr_code_count_start = qr_code_count()

      {{status, _changeset, _message}, logs} =
        with_log(fn ->
          QrCodeService.create_qr_code(@tts_attrs)
        end)

      qr_code_count_end = qr_code_count()

      assert status == :error
      assert logs =~ "deleting qr code after creation"
      assert qr_code_count_start == qr_code_count_end
    end

    test "create_qr_code/1 deletes a qr_code when the tts file could be retrieved from API, but not stored in the object storage" do
      mockTtsServiceSuccess()
      mockStorageServicePutObjectError()

      qr_code_count_start = qr_code_count()

      {{status, _changeset, _message}, logs} =
        with_log(fn ->
          QrCodeService.create_qr_code(@tts_attrs)
        end)

      qr_code_count_end = qr_code_count()

      assert status == :error
      assert logs =~ "deleting qr code after creation"
      assert qr_code_count_start == qr_code_count_end
    end
  end

  describe "create_qr_code/1 for recording codes" do
    @tag :tmp_dir
    test "create_qr_code/1 returns :ok for tts codes", %{tmp_dir: tmp_dir} do
      # create dummy file for test:
      file_path = writeTmpFile(tmp_dir)

      params = %{
        @recording_attrs
        | "audio_file" => %Plug.Upload{path: file_path, content_type: "audio/mp3", filename: "recording.mp3"}
      }

      mockStorageServicePutObjectSuccess()
      {:ok, qr_code} = QrCodeService.create_qr_code(params)
      assert qr_code.text == "a"
    end

    test "create_qr_code/1 deletes a qr_code when the recording could not be retrieved" do
      qr_code_count_start = qr_code_count()

      {{status, _changeset, _message}, logs} =
        with_log(fn ->
          QrCodeService.create_qr_code(@recording_attrs)
        end)

      qr_code_count_end = qr_code_count()

      assert status == :error
      assert logs =~ "deleting qr code after creation"
      assert qr_code_count_start == qr_code_count_end
    end

    @tag :tmp_dir
    test "create_qr_code/1 deletes a qr_code when the recording file could be retrieved, but not stored in the object storage",
         %{tmp_dir: tmp_dir} do
      mockStorageServicePutObjectError()

      # create dummy file for test:
      file_path = writeTmpFile(tmp_dir)

      params = %{
        @recording_attrs
        | "audio_file" => %Plug.Upload{path: file_path, content_type: "audio/mp3", filename: "recording.mp3"}
      }

      qr_code_count_start = qr_code_count()

      {{status, _changeset, _message}, logs} =
        with_log(fn ->
          QrCodeService.create_qr_code(params)
        end)

      qr_code_count_end = qr_code_count()

      assert status == :error
      assert logs =~ "deleting qr code after creation"
      assert qr_code_count_start == qr_code_count_end
    end
  end
end
