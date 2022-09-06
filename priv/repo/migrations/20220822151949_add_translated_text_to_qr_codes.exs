defmodule Qrstorage.Repo.Migrations.AddTranslatedTextToQrCodes do
  use Ecto.Migration

  def change do
    alter table(:qrcodes) do
      add :translated_text, :string
    end
  end
end
