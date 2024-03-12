defmodule Qrstorage.Worker.RemoveCodesWorker do
  use Oban.Worker, unique: [fields: [:worker], period: 60]
  alias Qrstorage.QrCodes
  alias Qrstorage.Services.StorageService

  require Logger

  @impl Oban.Worker
  def perform(_job) do
    Logger.info("Starting to delete old qr codes")
    {deleted_count, deleted_codes} = QrCodes.delete_old_qr_codes()

    # filter for recording codes, we need to delete the content from the object storage:
    ids_to_delete =
      deleted_codes
      |> Enum.filter(fn code -> code.content_type == :recording end)
      |> Enum.map(fn code ->
        code.id
      end)

    if Enum.empty?(ids_to_delete) do
      Logger.info("No codes to delete from object storage.")
    else
      Logger.info("Deleting codes with id from object storage: #{ids_to_delete}")
      StorageService.delete_recordings(ids_to_delete)
    end

    Logger.info("Finished deleting old qr codes: #{deleted_count}")

    :ok
  end
end
