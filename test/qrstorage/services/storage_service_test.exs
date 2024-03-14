defmodule Qrstorage.Services.StorageServiceTest do
  use Qrstorage.DataCase

  alias Qrstorage.Services.StorageService

  import Mox
  import ExUnit.CaptureLog

  describe "get_recording/1" do
    test "get_recording/1 with a 200 result from the object storage service returns :ok" do
      mock_file_content = "binary file content"

      Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock
      |> expect(:get_object, fn _bucket_name, _bucket_path ->
        {:ok, %{status_code: 200, body: mock_file_content}}
      end)

      {status, file_content} = StorageService.get_recording("1")
      assert status == :ok
      assert file_content == mock_file_content
    end

    test "get_recording/1 with a 404 result from the object storage service returns :error" do
      Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock
      |> expect(:get_object, fn _bucket_name, _bucket_path ->
        {:ok, %{status_code: 404, body: "File not found"}}
      end)

      {{status, _error}, log} =
        with_log(fn ->
          StorageService.get_recording("1")
        end)

      assert status == :error
      assert log =~ "Issue while loading file"
    end

    test "get_recording/1 with an error status from the object storage service returns :error" do
      Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock
      |> expect(:get_object, fn _bucket_name, _bucket_path ->
        {:error, {"http error", 500, %{body: "response"}}}
      end)

      {{status, _error}, log} =
        with_log(fn ->
          StorageService.get_recording("1")
        end)

      assert status == :error
      assert log =~ "Issue while loading file"
    end
  end

  describe "store_recording/3" do
    test "store_recording/3 with a 200 result from the object storage service returns :ok" do
      mock_file = "binary file content"
      audio_file_type = "audio/mp3"

      Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock
      |> expect(:put_object, fn _bucket_name, bucket_path, _file, _opts ->
        assert bucket_path == "audio/recording/1.mp3"
        {:ok, %{}}
      end)

      assert StorageService.store_recording("1", mock_file, audio_file_type) == {:ok}
    end

    test "store_recording/3 uses correct meta data" do
      mock_file = "binary file content"
      audio_file_type = "audio/mp3"

      Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock
      |> expect(:put_object, fn _bucket_name, _bucket_path, _file, opts ->
        assert opts[:content_type] == "audio/mp3"
        assert opts[:meta]["qr-code-content-type"] == "recording"
        {:ok, %{}}
      end)

      assert StorageService.store_recording("1", mock_file, audio_file_type) == {:ok}
    end

    test "store_recording/3 with an error returns :error" do
      mock_file = "binary file content"
      audio_file_type = "audio/mp3"

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
      audio_file_type = "wrong"

      assert StorageService.store_recording("1", mock_file, audio_file_type) == {:error, "Audio file type is not mp3"}
    end
  end

  describe "delete_recordings/1" do
    test "delete_recordings/1 returns :ok when files have been deleted" do
      Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock
      |> expect(:delete_all_objects, fn _bucket_name, ids_to_delete ->
        assert ids_to_delete == ["audio/recording/1.mp3", "audio/recording/2.mp3"]

        {:ok, [%{body: "1, 2"}]}
      end)

      ids = ["1", "2"]
      assert StorageService.delete_recordings(ids) == {:ok}
    end

    test "delete_recordings/1 returns :ok when file list is empty" do
      Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock
      |> expect(:delete_all_objects, fn _bucket_name, ids_to_delete ->
        assert ids_to_delete == []

        {:ok, []}
      end)

      ids = []
      assert StorageService.delete_recordings(ids) == {:ok}
    end

    test "delete_recordings/1 with an error returns :error" do
      Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock
      |> expect(:delete_all_objects, fn _bucket_name, _ids_to_delete ->
        {:error, {"http error", 500, %{body: "response"}}}
      end)

      {{status, _error}, log} =
        with_log(fn ->
          StorageService.delete_recordings(["1", "2"])
        end)

      assert status == :error
      assert log =~ "Error type"
    end
  end

  describe "get_tts/1" do
    test "get_tts/1 with a 200 result from the object storage service returns :ok" do
      mock_file_content = "binary file content"

      Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock
      |> expect(:get_object, fn _bucket_name, _bucket_path ->
        {:ok, %{status_code: 200, body: mock_file_content}}
      end)

      {status, file_content} = StorageService.get_tts("1")
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

      assert StorageService.store_tts("1", mock_file, audio_file_type) == {:error, "Audio file type is not mp3"}
    end
  end

  describe "delete_tts/1" do
    test "delete_tts/1 returns :ok when files have been deleted" do
      Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock
      |> expect(:delete_all_objects, fn _bucket_name, ids_to_delete ->
        assert ids_to_delete == ["audio/tts/1.mp3", "audio/tts/2.mp3"]

        {:ok, [%{body: "1, 2"}]}
      end)

      ids = ["1", "2"]
      assert StorageService.delete_tts(ids) == {:ok}
    end
  end
end
