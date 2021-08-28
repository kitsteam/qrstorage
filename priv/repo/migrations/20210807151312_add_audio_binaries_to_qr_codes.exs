defmodule Qrstorage.Repo.Migrations.AddAudioBinariesToQrCodes do
  use Ecto.Migration

  def change do
    alter table(:qrcodes) do
      add :audio_file, :binary
      add :audio_file_type, :string
    end
  end
end
