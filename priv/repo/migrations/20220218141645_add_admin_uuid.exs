defmodule Qrstorage.Repo.Migrations.AddAdminUuid do
  use Ecto.Migration

  def up do
    execute("CREATE EXTENSION IF NOT EXISTS \"pgcrypto\";")

    alter table(:qrcodes) do
      add :admin_url_id, :binary_id, default: fragment("gen_random_uuid()")
    end
  end

  def down do
    alter table(:qrcodes) do
      remove :admin_url_id
    end

    execute("DROP EXTENSION IF EXISTS \"pgcrypto\";")
  end
end
