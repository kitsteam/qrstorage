defmodule Qrstorage.Repo.Migrations.AddDeleteAfterMonths do
  alias Qrstorage.QrCodes.QrCodeMigrationHelper
  use Ecto.Migration

  def change do
    alter table(:qrcodes) do
      add :delete_after_months, :integer, default: 1
    end

    execute(&execute_up/0, &execute_down/0)
  end

  defp execute_up,
    do: QrCodeMigrationHelper.add_delete_after_months(repo())

  defp execute_down, do: nil
end
