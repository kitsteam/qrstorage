defmodule Qrstorage.Repo.Migrations.CreateQrcodes do
  use Ecto.Migration

  def change do
    create table(:qrcodes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :text, :text
      add :delete_after, :date

      timestamps()
    end

  end
end
