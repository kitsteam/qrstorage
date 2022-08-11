defmodule Qrstorage.Repo.Migrations.AddVoiceToQrCodes do
  use Ecto.Migration

  def change do
    alter table(:qrcodes) do
      add :voice, :string
    end

    # See [0] why we don't use elixir code for this:
    # [0] https://appunite.com/blog/why-shouldnt-you-use-elixir-code-in-database-migrations
    # We default to female, since this was the only option before:
    execute("""
      UPDATE qrcodes
      SET voice = 'female';
    """)
  end
end
