defmodule Qrstorage.Services.ObjectStorage.ObjectStorageServiceImpl do
  alias Qrstorage.Services.ObjectStorage.ObjectStorageService

  @behaviour ObjectStorageService

  alias ExAws.S3

  require Logger

  @impl ObjectStorageService
  # See https://hexdocs.pm/elixir_mock/getting_started.html for why we are doing it this way:
  @spec get_object(binary(), binary()) :: {:error, any()} | {:ok, any()}
  def get_object(bucket_name, bucket_path) do
    S3.get_object(bucket_name, bucket_path) |> ExAws.request()
  end

  @impl ObjectStorageService
  def put_object(bucket_name, bucket_path, file) do
    S3.put_object(bucket_name, bucket_path, file) |> ExAws.request()
  end

  @impl ObjectStorageService
  def delete_all_objects(bucket_name, files_to_delete) do
    S3.delete_all_objects(bucket_name, files_to_delete) |> ExAws.request()
  end
end
