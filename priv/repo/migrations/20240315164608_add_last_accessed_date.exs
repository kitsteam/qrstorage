defmodule Qrstorage.Repo.Migrations.AddLastAccessedDate do
  use Ecto.Migration

  def change do
    alter table(:qrcodes) do
      add :last_accessed_at, :utc_datetime, default: fragment("now()")
    end
  end
end
