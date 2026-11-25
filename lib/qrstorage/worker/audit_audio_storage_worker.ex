defmodule Qrstorage.Worker.AuditAudioStorageWorker do
  @moduledoc """
  Weekly read-only check for audio files in the object storage that have no matching qr code.
  The result is only logged, nothing is deleted. See docs/adr/0002-audit-orphaned-audio-files.md.
  """
  use Oban.Worker, queue: :audit, unique: [fields: [:worker], period: 60]

  alias Qrstorage.Services.StorageAudit

  require Logger

  @impl Oban.Worker
  def perform(_job) do
    Logger.info("Starting audit of audio files in object storage")

    case StorageAudit.find_orphans() do
      {:ok, %{orphans: [], unrecognized: []} = report} ->
        Logger.info(StorageAudit.format_report(report))
        :ok

      {:ok, report} ->
        Logger.warning(StorageAudit.format_report(report))
        :ok

      {:error, reason} ->
        Logger.error("Audit of audio files in object storage failed: #{inspect(reason)}")
        {:error, reason}
    end
  end
end
