defmodule Qrstorage.Worker.RemoveCodesWorker do
  use Oban.Worker, unique: [fields: [:worker], period: 60]
  alias Qrstorage.QrCodes
  alias Qrstorage.Services.StorageService

  require Logger

  @impl Oban.Worker
  def perform(_job) do
    Logger.info("Starting to delete old qr codes")
    {deleted_count, deleted_codes} = QrCodes.delete_old_qr_codes()
    delete_recordings(deleted_codes)
    delete_tts(deleted_codes)
    Logger.info("Finished deleting old qr codes: #{deleted_count}")

    :ok
  end

  defp delete_recordings(deleted_codes) do
    # filter for recording codes, we need to delete the content from the object storage:
    recording_ids_to_delete = ids_by_filtered_codes(deleted_codes, :recording)

    if Enum.empty?(recording_ids_to_delete) do
      Logger.info("No recording codes to delete from object storage.")
    else
      Logger.info("Deleting recording codes with id from object storage: #{recording_ids_to_delete}")
      StorageService.delete_recordings(recording_ids_to_delete)
    end
  end

  defp delete_tts(deleted_codes) do
    # filter for recording codes, we need to delete the content from the object storage:
    tts_ids_to_delete = ids_by_filtered_codes(deleted_codes, :audio)

    if Enum.empty?(tts_ids_to_delete) do
      Logger.info("No tts codes to delete from object storage.")
    else
      Logger.info("Deleting tts codes with id from object storage: #{tts_ids_to_delete}")
      StorageService.delete_tts(tts_ids_to_delete)
    end
  end

  defp ids_by_filtered_codes(codes, filter) do
    codes
    |> Enum.filter(fn code -> code.content_type == filter end)
    |> Enum.map(fn code ->
      code.id
    end)
  end
end
