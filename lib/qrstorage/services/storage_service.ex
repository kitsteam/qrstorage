defmodule Qrstorage.Services.StorageService do
  alias Qrstorage.Services.ObjectStorage.ObjectStorageService
  require Logger

  def get_recording(id) do
    get_file(recording_filename(id), "recording")
  end

  def store_recording(id, audio_file, audio_file_type) when audio_file_type == "audio/mp3" do
    store_file(recording_filename(id), audio_file, "recording")
  end

  def store_recording(_id, _audio_file, _audio_file_type),
    do: {:error, "Audio file type is not mp3"}

  def delete_recordings(ids) do
    files_to_delete = Enum.map(ids, fn id -> bucket_path(recording_filename(id), "recording") end)

    delete_files(files_to_delete)
  end

  defp get_file(filename, type) do
    case ObjectStorageService.get_object(bucket_name(), bucket_path(filename, type)) do
      {:ok, response} ->
        case response.status_code do
          200 ->
            {:ok, response.body}

          _ ->
            Logger.error(
              "Issue while loading file. Response code: #{response.status_code} Response Body: #{response.body}"
            )

            {:error, "Issue while loading file."}
        end

      {:error, {error_type, http_status_code, response}} ->
        Logger.error(
          "Issue while loading file. Error type: #{error_type} Response code: #{http_status_code} Response Body: #{response.body}"
        )

        {:error, "Issue while loading file."}
    end
  end

  defp store_file(filename, file, type) do
    case ObjectStorageService.put_object(bucket_name(), bucket_path(filename, type), file) do
      {:ok, _} ->
        {:ok}

      {:error, {error_type, http_status_code, response}} ->
        Logger.error(
          "Error storing file in bucket: #{filename} Type: #{type}. Error type: #{error_type} Response code: #{http_status_code} Response Body: #{response.body}"
        )

        {:error, "Issue while storing file."}
    end
  end

  defp delete_files(files_to_delete) do
    # If this request fails, we currently need to manually delete the old files. We could also implement a lifecyle policy, so that this cleanup happens automatically:
    case ObjectStorageService.delete_all_objects(bucket_name(), files_to_delete) do
      {:ok, []} ->
        # this can happen when the files_to_delete is empty. We'll catch this earlier as well to save us a request.
        {:ok}

      {:ok, [response]} ->
        Logger.info("Success while deleting files.")
        Logger.debug("Deleted files: #{response.body}")
        {:ok}

      {:error, {error_type, http_status_code, response}} ->
        Logger.error("Error type: #{error_type} Response code: #{http_status_code} Response Body: #{response.body}")
        {:error, "Files not deleted"}
    end
  end

  defp recording_filename(id) do
    id <> ".mp3"
  end

  defp bucket_name do
    System.fetch_env!("OBJECT_STORAGE_BUCKET")
  end

  defp bucket_path(filename, type) do
    "audio/#{type}/#{filename}"
  end
end
