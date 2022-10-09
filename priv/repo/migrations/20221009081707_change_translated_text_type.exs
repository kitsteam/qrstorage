defmodule Qrstorage.Repo.Migrations.ChangeTranslatedTextType do
  use Ecto.Migration

  def change do
    alter table(:qrcodes) do
      modify :translated_text, :text, from: :string
    end
  end
end
