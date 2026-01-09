defmodule Qrstorage.StorageCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the Object Storage
  """
  import Mox
  use ExUnit.CaseTemplate
  alias Qrstorage.Services.Vault

  using do
    quote do
      import Qrstorage.StorageCase
      import Mox
      setup :verify_on_exit!
    end
  end

  def mockStorageServicePutObjectSuccess(mock_file_content \\ "mock http body", assert_file_content \\ nil) do
    Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock
    |> expect(:put_object, fn _bucket_name, _bucket_path, _file, _opts ->
      if assert_file_content != nil do
        assert mock_file_content == assert_file_content
      end

      {:ok, %{status_code: 200, body: Vault.encrypt!(mock_file_content)}}
    end)
  end

  def mockStorageServicePutObjectError() do
    Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock
    |> expect(:put_object, fn _bucket_name, _bucket_path, _file, _opts ->
      {:error, {"http error", 500, %{body: "response"}}}
    end)
  end

  def mockStorageServiceDeleteAllSuccess(qr_codes_to_delete, assert_objects_to_delete \\ nil) do
    Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock
    |> expect(:delete_all_objects, fn _bucket_name, objects_to_delete ->
      if assert_objects_to_delete do
        assert objects_to_delete == assert_objects_to_delete
      end

      {:ok, [%{body: qr_codes_to_delete}]}
    end)
  end

  def mockStorageServiceGetFileSuccess(file, assert_file_content \\ nil) do
    Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock
    |> expect(:get_object, fn _bucket_name, _bucket_path ->
      if assert_file_content do
        assert file == assert_file_content
      end

      {:ok, %{status_code: 200, body: Vault.encrypt!(file)}}
    end)
  end

  def writeTmpFile(tmp_dir, filename \\ "recording.mp3", content \\ "binary audio content") do
    file_path = Path.join(tmp_dir, filename)
    File.write(file_path, content)
    file_path
  end
end
