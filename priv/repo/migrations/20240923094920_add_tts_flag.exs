defmodule Qrstorage.Repo.Migrations.AddTtsFlag do
  alias Qrstorage.QrCodes.QrCodeMigrationHelper

  use Ecto.Migration

  def change do
    alter table(:qrcodes) do
      add :tts, :boolean, default: false
    end

    execute(&execute_up/0, &execute_down/0)
  end

  defp execute_up,
    do: QrCodeMigrationHelper.add_tts_to_existing_audio_codes(repo())

  defp execute_down, do: nil
end
