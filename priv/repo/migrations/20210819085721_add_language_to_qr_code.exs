defmodule Qrstorage.Repo.Migrations.AddLanguageToQrCode do
  use Ecto.Migration

  def change do
    alter table(:qrcodes) do
      add :language, :string
    end
  end
end
