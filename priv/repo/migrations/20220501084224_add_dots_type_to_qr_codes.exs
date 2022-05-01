defmodule Qrstorage.Repo.Migrations.AddDotsTypesToQrCodes do
  use Ecto.Migration

  def change do
    alter table(:qrcodes) do
      add :dots_type, :string
    end

    # See [0] why we don't use elixir code for this:
    # [0] https://appunite.com/blog/why-shouldnt-you-use-elixir-code-in-database-migrations
    # We default to dots
    execute("""
      UPDATE qrcodes
      SET dots_type = 'dots';
    """)
  end
end
