defmodule Qrstorage.Repo.Migrations.AddHideOption do
  use Ecto.Migration

  def change do
    alter table(:qrcodes) do
      add :hide_text, :boolean, default: true
    end
  end
end
