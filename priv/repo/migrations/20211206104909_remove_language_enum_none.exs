defmodule Qrstorage.Repo.Migrations.RemoveLanguageEnumNone do
  use Ecto.Migration

  def change do
    execute("""
      UPDATE qrcodes
      SET language = NULL
      WHERE language = 'none';
    """)
  end
end
