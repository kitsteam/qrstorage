defmodule Qrstorage.Services.ObjectStorage.ObjectStorageService do
  @callback get_object(binary(), binary()) :: {:error, any()} | {:ok, any()}
  @callback put_object(binary(), binary(), binary(), ExAws.S3.put_object_opts()) :: {:error, any()} | {:ok, any()}
  @callback delete_all_objects(binary(), [binary() | {binary(), binary()}, ...] | Enumerable.t()) ::
              {:error, any()} | {:ok, any()}

  # See https://hexdocs.pm/elixir_mock/getting_started.html for why we are doing it this way:
  def get_object(bucket_name, bucket_path), do: impl().get_object(bucket_name, bucket_path)

  def put_object(bucket_name, bucket_path, file, opts \\ []),
    do: impl().put_object(bucket_name, bucket_path, file, opts)

  def delete_all_objects(bucket_name, files_to_delete), do: impl().delete_all_objects(bucket_name, files_to_delete)

  defp impl,
    do:
      Application.get_env(
        :qrstorage,
        :object_storage_service,
        Qrstorage.Services.ObjectStorage.ObjectStorageServiceImpl
      )
end
