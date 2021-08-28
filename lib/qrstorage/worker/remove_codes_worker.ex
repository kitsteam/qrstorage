defmodule Qrstorage.Worker.RemoveCodesWorker do
  use Oban.Worker, unique: [fields: [:worker], period: 60]
  alias Qrstorage.QrCodes

  @impl Oban.Worker
  def perform(_job) do
    QrCodes.delete_old_qr_codes()

    :ok
  end
end
