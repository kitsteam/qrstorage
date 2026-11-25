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
  def put_object(bucket_name, bucket_path, file, opts) do
    S3.put_object(bucket_name, bucket_path, file, opts) |> ExAws.request()
  end

  @impl ObjectStorageService
  def delete_all_objects(bucket_name, files_to_delete) do
    S3.delete_all_objects(bucket_name, files_to_delete) |> ExAws.request()
  end

  @impl ObjectStorageService
  def list_objects(bucket_name, prefix) do
    objects =
      S3.list_objects_v2(bucket_name, prefix: prefix)
      |> ExAws.stream!()
      |> Enum.map(fn object -> %{key: object.key, last_modified: parse_datetime(object[:last_modified])} end)

    {:ok, objects}
  rescue
    error -> {:error, error}
  end

  defp parse_datetime(value) when is_binary(value) do
    case DateTime.from_iso8601(value) do
      {:ok, datetime, _offset} -> datetime
      _ -> nil
    end
  end

  defp parse_datetime(_), do: nil
end
