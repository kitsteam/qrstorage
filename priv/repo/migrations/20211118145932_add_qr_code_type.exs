defmodule Qrstorage.Repo.Migrations.AddQrCodeType do
  use Ecto.Migration

  def change do
    alter table(:qrcodes) do
      add :content_type, :string
    end

    # See [0] why we don't use elixir code for this:
    # [0] https://appunite.com/blog/why-shouldnt-you-use-elixir-code-in-database-migrations
    execute("""
      UPDATE qrcodes
      SET content_type = (CASE WHEN language = 'none' THEN 'text' ELSE 'audio' END);
    """)
  end
end
