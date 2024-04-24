defmodule Qrstorage.Services.StorageService do
  alias Qrstorage.Services.ObjectStorage.ObjectStorageService
  alias Qrstorage.Services.Vault
  require Logger

  def get_file_by_type(id, :recording) do
    get_recording(id)
  end

  def get_file_by_type(id, :audio) do
    get_tts(id)
  end

  # methods for recordings:
  def get_recording(id) do
    get_file(audio_filename(id), "recording")
  end

  def store_recording(id, audio_file, audio_file_type) when audio_file_type == "audio/mp3" do
    store_file(audio_filename(id), audio_file, "recording", audio_file_type)
  end

  def store_recording(_id, _audio_file, _audio_file_type),
    do: {:error, "Audio file type is not mp3"}

  def delete_recordings(ids) do
    delete_audio_files(ids, "recording")
  end

  # methods for tts:
  def get_tts(id) do
    get_file(audio_filename(id), "tts")
  end

  def store_tts(id, audio_file, audio_file_type) when audio_file_type == "audio/mp3" do
    store_file(audio_filename(id), audio_file, "tts", audio_file_type)
  end

  def store_tts(_id, _audio_file, _audio_file_type),
    do: {:error, "Audio file type is not mp3"}

  def delete_tts(ids) do
    delete_audio_files(ids, "tts")
  end

  defp get_file(filename, type) do
    case ObjectStorageService.get_object(bucket_name(), bucket_path(filename, type)) do
      {:ok, response} ->
        case response.status_code do
          200 ->
            case Vault.decrypt(response.body) do
              {:ok, decrypted_file} -> {:ok, decrypted_file}
              {:error, error_message} -> {:error, "Issue while decrypting file: #{inspect(error_message)}"}
            end

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

  defp store_file(filename, file, qr_code_content_type, content_type) do
    case Vault.encrypt(file) do
      {:ok, encrypted_file} -> store_encrypted_file(filename, encrypted_file, qr_code_content_type, content_type)
      {:error, error_message} -> {:error, "Issue while encrypting file: #{inspect(error_message)}"}
    end
  end

  defp store_encrypted_file(filename, encrypted_file, qr_code_content_type, content_type) do
    case ObjectStorageService.put_object(bucket_name(), bucket_path(filename, qr_code_content_type), encrypted_file, %{
           meta: %{"qr-code-content-type" => qr_code_content_type},
           content_type: content_type
         }) do
      {:ok, _} ->
        {:ok}

      {:error, {error_type, http_status_code, response}} ->
        Logger.error(
          "Error storing file in bucket: #{filename} Type: #{qr_code_content_type}. Error type: #{error_type} Response code: #{http_status_code} Response Body: #{response.body}"
        )

        {:error, "Issue while storing file."}
    end
  end

  defp delete_audio_files(ids, path) do
    files_to_delete = Enum.map(ids, fn id -> bucket_path(audio_filename(id), path) end)

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

  defp audio_filename(id) do
    id <> ".mp3"
  end

  defp bucket_name do
    System.fetch_env!("OBJECT_STORAGE_BUCKET")
  end

  defp bucket_path(filename, type) do
    "audio/#{type}/#{filename}"
  end
end
