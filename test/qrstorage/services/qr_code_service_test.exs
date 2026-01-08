defmodule Qrstorage.Services.QrCodeServiceTest do
  use Qrstorage.DataCase
  use Qrstorage.ApiCase
  use Qrstorage.StorageCase
  use Qrstorage.RateLimitingCase

  alias Qrstorage.Services.QrCodeService

  import ExUnit.CaptureLog

  @create_attrs %{
    "text" => "some text",
    "deltas" => "{\"ops\":[{\"insert\":\"Assad\\n\"}]}",
    "language" => nil,
    "content_type" => "text",
    "dots_type" => "dots",
    "voice" => nil,
    "hp" => nil
  }

  @translation_attrs %{
    "text" => "some text",
    "content_type" => "audio",
    "voice" => "female",
    "language" => "de",
    "dots_type" => "dots",
    "hp" => nil,
    "tts" => "false"
  }

  @tts_attrs %{
    "text" => "some text",
    "content_type" => "audio",
    "voice" => "female",
    "language" => "de",
    "dots_type" => "dots",
    "hp" => nil,
    "tts" => "true"
  }

  @recording_attrs %{
    "text" => "a",
    "content_type" => "recording",
    "dots_type" => "dots",
    "hp" => nil,
    "audio_file" => nil,
    "delete_after_months" => "1",
    "audio_file_type" => "audio/webm"
  }

  @link_attrs %{
    "text" => "https://kits.blog",
    "content_type" => "link",
    "dots_type" => "dots",
    "delete_after_months" => "0"
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

    test "create_qrcode/1 returns :error, when a link code has a delete_after_months date set to something else than 0" do
      invalid_attrs = %{@link_attrs | "delete_after_months" => "2"}

      {:error, changeset} = QrCodeService.create_qr_code(invalid_attrs)
      assert "Storage duration is invalid" in errors_on(changeset).delete_after_months
    end

    test "create_qrcode/1 returns :ok, when a link code has a delete_after_months date set to 0" do
      valid_attrs = %{@link_attrs | "delete_after_months" => "0"}

      {:ok, qr_code} = QrCodeService.create_qr_code(valid_attrs)
      assert qr_code.text == "https://kits.blog"
    end

    for months <- ["1", "24", "48"] do
      @tag :tmp_dir
      test "create_qrcode/1 returns :ok, when a recording code has a delete_after_months date set to #{months}", %{
        tmp_dir: tmp_dir
      } do
        # create dummy file for test:
        file_path = writeTmpFile(tmp_dir)

        params = %{
          @recording_attrs
          | "audio_file" => %Plug.Upload{path: file_path, content_type: "audio/webm", filename: "recording.webm"},
            "delete_after_months" => unquote(months)
        }

        mockStorageServicePutObjectSuccess()

        {:ok, qr_code} = QrCodeService.create_qr_code(params)
        assert qr_code.text == "a"
        assert qr_code.audio_file_type == "audio/webm"
      end
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

    test "create_qr_code/1 does not call tts when the tts value is false" do
      mock_language_service_success()
      {:ok, qr_code} = QrCodeService.create_qr_code(@translation_attrs)

      assert qr_code.tts == false
    end

    test "create_qr_code/1 does not create code when rate limit has been reached" do
      qr_code_count_start = qr_code_count()

      {{status, _changeset, _message}, logs} =
        with_log(fn ->
          with_rate_limit_set_to(1, fn -> QrCodeService.create_qr_code(@tts_attrs) end)
        end)

      qr_code_count_end = qr_code_count()

      assert status == :error
      assert logs =~ "Rate Limit reached"
      assert logs =~ "deleting qr code after creation"
      assert qr_code_count_start == qr_code_count_end
    end
  end

  describe "create_qr_code/1 for recording codes" do
    @tag :tmp_dir
    test "create_qr_code/1 returns :ok for recording codes", %{tmp_dir: tmp_dir} do
      # create dummy file for test:
      file_path = writeTmpFile(tmp_dir)

      params = %{
        @recording_attrs
        | "audio_file" => %Plug.Upload{path: file_path, content_type: "audio/webm", filename: "recording.webm"}
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
        | "audio_file" => %Plug.Upload{path: file_path, content_type: "audio/webm", filename: "recording.webm"}
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
