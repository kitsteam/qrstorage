defmodule Qrstorage.Worker.RemoveCodesWorker do
  use Oban.Worker, unique: [fields: [:worker], period: 60]
  alias Qrstorage.QrCodes

  require Logger

  @impl Oban.Worker
  def perform(_job) do
    Logger.info("Starting to delete old qr codes")
    deleted_count = QrCodes.delete_old_qr_codes()
    Logger.info("Finished deleting old qr codes: #{deleted_count}")

    :ok
  end
end
