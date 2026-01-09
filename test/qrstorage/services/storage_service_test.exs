defmodule Qrstorage.Services.StorageServiceTest do
  use Qrstorage.DataCase
  use Qrstorage.StorageCase

  alias Qrstorage.Services.StorageService
  alias Qrstorage.QrCodes.QrCode

  import Mox
  setup :verify_on_exit!
  import ExUnit.CaptureLog

  describe "get_recording/2" do
    test "get_recording/2 with a 200 result from the object storage service returns :ok" do
      mock_file_content = "binary file content"

      mockStorageServiceGetFileSuccess(mock_file_content)

      {status, file_content} = StorageService.get_recording("1", "audio/webm")
      assert status == :ok
      assert file_content == mock_file_content
    end

    test "get_recording/2 with a 404 result from the object storage service returns :error" do
      Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock
      |> expect(:get_object, fn _bucket_name, _bucket_path ->
        {:ok, %{status_code: 404, body: "File not found"}}
      end)

      {{status, _error}, log} =
        with_log(fn ->
          StorageService.get_recording("1", "audio/webm")
        end)

      assert status == :error
      assert log =~ "Issue while loading file"
    end

    test "get_recording/2 with an error status from the object storage service returns :error" do
      Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock
      |> expect(:get_object, fn _bucket_name, _bucket_path ->
        {:error, {"http error", 500, %{body: "response"}}}
      end)

      {{status, _error}, log} =
        with_log(fn ->
          StorageService.get_recording("1", "audio/webm")
        end)

      assert status == :error
      assert log =~ "Issue while loading file"
    end
  end

  describe "store_recording/3" do
    test "store_recording/3 with a 200 result from the object storage service returns :ok" do
      mock_file = "binary file content"
      audio_file_type = "audio/webm"

      Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock
      |> expect(:put_object, fn _bucket_name, bucket_path, _file, _opts ->
        assert bucket_path == "audio/recording/1.webm"
        {:ok, %{}}
      end)

      assert StorageService.store_recording("1", mock_file, audio_file_type) == {:ok}
    end

    test "store_recording/3 uses correct meta data" do
      mock_file = "binary file content"
      audio_file_type = "audio/webm"

      Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock
      |> expect(:put_object, fn _bucket_name, _bucket_path, _file, opts ->
        assert opts[:content_type] == "audio/webm"
        assert opts[:meta]["qr-code-content-type"] == "recording"
        {:ok, %{}}
      end)

      assert StorageService.store_recording("1", mock_file, audio_file_type) == {:ok}
    end

    test "store_recording/3 with an error returns :error" do
      mock_file = "binary file content"
      audio_file_type = "audio/webm"

      Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock
      |> expect(:put_object, fn _bucket_name, _bucket_path, _file, _opts ->
        {:error, {"http error", 500, %{body: "response"}}}
      end)

      {{status, _error}, log} =
        with_log(fn ->
          StorageService.store_recording("1", mock_file, audio_file_type)
        end)

      assert status == :error
      assert log =~ "Error storing file in bucket"
    end

    test "store_recording/3 with wrong file type returns :error" do
      mock_file = "binary file content"
      audio_file_type = "audio/mp3"

      assert StorageService.store_recording("1", mock_file, audio_file_type) ==
               {:error, "Audio file type for recording is not webm"}
    end
  end

  describe "delete_recordings/1" do
    test "delete_recordings/1 returns :ok when files have been deleted" do
      Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock
      |> expect(:delete_all_objects, fn _bucket_name, files_to_delete ->
        assert files_to_delete == ["audio/recording/1.mp3", "audio/recording/2.mp3", "audio/recording/3.webm"]

        {:ok, [%{body: "1, 2, 3"}]}
      end)

      qr_codes = [
        %QrCode{id: "1", audio_file_type: "audio/mp3"},
        %QrCode{id: "2", audio_file_type: nil},
        %QrCode{id: "3", audio_file_type: "audio/webm"}
      ]

      assert StorageService.delete_recordings(qr_codes) == {:ok}
    end

    test "delete_recordings/1 returns :ok when file list is empty" do
      Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock
      |> expect(:delete_all_objects, fn _bucket_name, files_to_delete ->
        assert files_to_delete == []

        {:ok, []}
      end)

      qr_codes = []
      assert StorageService.delete_recordings(qr_codes) == {:ok}
    end

    test "delete_recordings/1 with an error returns :error" do
      Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock
      |> expect(:delete_all_objects, fn _bucket_name, _ids_to_delete ->
        {:error, {"http error", 500, %{body: "response"}}}
      end)

      {{status, _error}, log} =
        with_log(fn ->
          StorageService.delete_recordings([%QrCode{id: "1"}, %QrCode{id: "2"}])
        end)

      assert status == :error
      assert log =~ "Error type"
    end
  end

  describe "get_tts/2" do
    test "get_tts/2 with a 200 result from the object storage service returns :ok" do
      mock_file_content = "binary file content"

      mockStorageServiceGetFileSuccess(mock_file_content)

      {status, file_content} = StorageService.get_tts("1", "audio/mp3")
      assert status == :ok
      assert file_content == mock_file_content
    end
  end

  describe "store_tts/3" do
    test "store_tts/3 with a 200 result from the object storage service returns :ok" do
      mock_file = "binary file content"
      audio_file_type = "audio/mp3"

      Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock
      |> expect(:put_object, fn _bucket_name, bucket_path, _file, _opts ->
        assert bucket_path == "audio/tts/1.mp3"
        {:ok, %{}}
      end)

      assert StorageService.store_tts("1", mock_file, audio_file_type) == {:ok}
    end

    test "store_tts/3 uses correct meta data" do
      mock_file = "binary file content"
      audio_file_type = "audio/mp3"

      Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock
      |> expect(:put_object, fn _bucket_name, _bucket_path, _file, opts ->
        assert opts[:content_type] == "audio/mp3"
        assert opts[:meta]["qr-code-content-type"] == "tts"
        {:ok, %{}}
      end)

      assert StorageService.store_tts("1", mock_file, audio_file_type) == {:ok}
    end

    test "store_tts/3 with wrong file type returns :error" do
      mock_file = "binary file content"
      audio_file_type = "wrong"

      assert StorageService.store_tts("1", mock_file, audio_file_type) == {:error, "Audio file type for TTS is not mp3"}
    end
  end

  describe "delete_tts/1" do
    test "delete_tts/1 returns :ok when files have been deleted" do
      Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock
      |> expect(:delete_all_objects, fn _bucket_name, files_to_delete ->
        assert files_to_delete == ["audio/tts/1.mp3", "audio/tts/2.mp3"]

        {:ok, [%{body: "1, 2"}]}
      end)

      qr_codes = [%QrCode{id: "1"}, %QrCode{id: "2"}]
      assert StorageService.delete_tts(qr_codes) == {:ok}
    end
  end
end
