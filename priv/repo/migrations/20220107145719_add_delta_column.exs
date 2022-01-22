defmodule Qrstorage.Repo.Migrations.AddDeltaColumn do
  use Ecto.Migration

  def change do
    alter table(:qrcodes) do
      add :deltas, :jsonb, null: false, default: "{}"
    end
  end
end
