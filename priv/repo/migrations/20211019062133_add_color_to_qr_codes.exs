defmodule Qrstorage.Repo.Migrations.AddColorToQrCodes do
  use Ecto.Migration

  def change do
    alter table(:qrcodes) do
      add :color, :string
    end
  end
end
