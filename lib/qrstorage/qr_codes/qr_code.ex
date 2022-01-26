defmodule Qrstorage.QrCodes.QrCode do
  use Ecto.Schema
  import Ecto.Changeset

  alias HtmlSanitizeEx
  alias HtmlSanitizeEx.Scrubber
  alias Qrstorage.Scrubber.TextScrubber

  @languages ~w[de en fr es tr pl ar ru it pt nl]a

  @colors ~w[black gold darkgreen darkslateblue midnightblue crimson]a
  @content_types ~w[link audio text]a

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "qrcodes" do
    field :delete_after, :date
    field :text, :string
    field :audio_file, :binary
    field :audio_file_type, :string
    field :language, Ecto.Enum, values: @languages
    field :color, Ecto.Enum, values: @colors
    field :hide_text, :boolean, default: true
    field :content_type, Ecto.Enum, values: @content_types
    field :deltas, :map

    timestamps()
  end

  @doc false
  def changeset(qr_code, attrs) do
    qr_code
    |> cast(attrs, [:text, :delete_after, :color, :language, :hide_text, :content_type, :deltas])
    |> sanitize_text
    |> validate_text_length(:text)
    |> validate_inclusion(:color, @colors)
    |> validate_inclusion(:content_type, @content_types)
    |> validate_audio_type(:content_type)
    |> validate_link(:text)
    |> validate_required([:text, :delete_after, :content_type])
  end

  def store_audio_file(qr_code, attrs) do
    qr_code
    |> cast(attrs, [:audio_file, :audio_file_type])
  end

  def languages do
    @languages
  end

  def colors do
    @colors
  end

  def content_types do
    @content_types
  end

  def validate_text_length(changeset, field) do
    validate_change(changeset, field, fn field, value ->
      max_count = 2000
      count = text_length(value, get_field(changeset, :content_type))

      if count <= max_count do
        []
      else
        [{field, "should be at most #{max_count} character(s)"}]
      end
    end)
  end

  def validate_link(changeset, field) do
    validate_change(changeset, field, fn field, value ->
      # we only check the type link, other types don't have to be a valid url:
      case get_field(changeset, :content_type) do
        :link ->
          if valid_url?(value), do: [], else: [{field, "Link is invalid"}]

        _ ->
          []
      end
    end)
  end

  def validate_audio_type(changeset, field) do
    validate_change(changeset, field, fn field, content_type ->
      # we only check the type audio, other types don't have to have a language.
      # We can't pass :language as a field since validate_change doesnt run on attributes that are nil
      case content_type do
        :audio ->
          if Enum.member?(@languages, get_field(changeset, :language)),
            do: [],
            else: [{:language, "Audio type requires language"}]

        _ ->
          []
      end
    end)
  end

  defp sanitize_text(changeset) do
    if Map.has_key?(changeset.changes, :text) && is_text(changeset),
      do: change(changeset, text: Scrubber.scrub(changeset.changes.text, TextScrubber)),
      else: changeset
  end

  defp is_text(changeset) do
    get_field(changeset, :content_type) == :text
  end

  defp text_length(text, :text) do
    String.length(HtmlSanitizeEx.strip_tags(text))
  end

  defp text_length(text, _) do
    String.length(text)
  end

  # This is a very simple check - it just verifies host/scheme.
  defp valid_url?(url) when is_binary(url) do
    case URI.parse(url) do
      %URI{host: nil} -> false
      %URI{scheme: nil} -> false
      %URI{} -> true
    end
  end

  defp valid_url?(_), do: false
end
