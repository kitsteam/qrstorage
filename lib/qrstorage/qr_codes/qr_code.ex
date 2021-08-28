defmodule Qrstorage.QrCodes.QrCode do
  use Ecto.Schema
  import Ecto.Changeset

  @languages ~w[none de en fr es tr]a

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "qrcodes" do
    field :delete_after, :date
    field :text, :string
    field :audio_file, :binary
    field :audio_file_type, :string
    field :language, Ecto.Enum, values: @languages

    timestamps()
  end

  @doc false
  def changeset(qr_code, attrs) do
    qr_code
    |> cast(attrs, [:text, :delete_after, :language])
    |> validate_inclusion(:language, @languages)
    |> validate_required([:text, :delete_after, :language])
  end

  def store_audio_file(qr_code, attrs) do
    qr_code
    |> cast(attrs, [:audio_file, :audio_file_type])
  end

  def languages do
    @languages
  end
end
