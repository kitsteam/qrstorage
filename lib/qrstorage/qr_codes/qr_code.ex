defmodule Qrstorage.QrCodes.QrCode do
  use Ecto.Schema
  import Ecto.Changeset

  alias FastSanitize
  alias FastSanitize.Sanitizer
  alias Qrstorage.Scrubber.TextScrubber

  require Logger

  @languages ~w[de en fr es tr pl ar ru it pt nl uk]a
  @block_list ~w[https http www]

  @voices ~w[male female]a

  @colors ~w[black gold darkgreen darkslateblue midnightblue crimson]a
  @content_types ~w[link audio text recording]a

  @dots_types ~w[dots square]a

  @text_length_limits %{link: 1500, audio: 2000, text: 4000, recording: 1}

  @max_delete_after_year 9999

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "qrcodes" do
    field :delete_after, :date
    field :text, :string
    field :translated_text, :string
    field :audio_file, :binary
    field :audio_file_type, :string
    field :language, Ecto.Enum, values: @languages
    field :color, Ecto.Enum, values: @colors
    field :hide_text, :boolean, default: true
    field :content_type, Ecto.Enum, values: @content_types
    field :deltas, :map
    field :admin_url_id, :binary_id, read_after_writes: true
    field :dots_type, Ecto.Enum, values: @dots_types
    field :voice, Ecto.Enum, values: @voices
    field :hp, :string, virtual: true
    field :last_accessed_at, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(qr_code, attrs) do
    qr_code
    |> cast(attrs, [
      :text,
      :delete_after,
      :color,
      :language,
      :hide_text,
      :content_type,
      :deltas,
      :dots_type,
      :voice,
      :hp
    ])
    |> validate_length(:hp, is: 0)
    |> scrub_text
    |> validate_text_length(:text)
    |> validate_inclusion(:color, @colors)
    |> validate_inclusion(:content_type, @content_types)
    |> validate_inclusion(:dots_type, @dots_types)
    |> validate_audio_type(:content_type)
    |> validate_link(:text)
    |> validate_required([:text, :delete_after, :content_type, :dots_type])
  end

  def store_audio_file(qr_code, attrs) do
    qr_code
    |> cast(attrs, [:audio_file, :audio_file_type])
  end

  def changeset_with_translated_text(qr_code, translated_text) do
    qr_code
    |> change(%{translated_text: translated_text})
  end

  def changeset_with_upated_last_accessed_at(qr_code) do
    qr_code
    |> change(%{last_accessed_at: DateTime.truncate(DateTime.utc_now(), :second)})
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

  def text_length_limits do
    @text_length_limits
  end

  def max_delete_after_year do
    @max_delete_after_year
  end

  def dots_types do
    @dots_types
  end

  def stored_indefinitely?(qr_code) do
    qr_code.delete_after.year == max_delete_after_year()
  end

  def default_dots_type do
    List.first(@dots_types)
  end

  def validate_text_length(changeset, field) do
    validate_change(changeset, field, fn field, value ->
      content_type = get_field(changeset, :content_type)
      count = text_length(value, content_type)
      max_characters_count = @text_length_limits[content_type]

      if count <= max_characters_count do
        []
      else
        [{field, "Text is too long"}]
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
    validate_change(changeset, field, fn _field, content_type ->
      # we only check the type audio and recording, other types don't have to have a language and a voice
      # We can't pass :language or :voice as a field since validate_change doesnt run on attributes that are nil
      case content_type do
        :audio ->
          [] ++ check_language(changeset) ++ check_voice(changeset) ++ check_block_list(changeset)

        _ ->
          []
      end
    end)
  end

  def translation_changed_text(qr_code) do
    qr_code.text != qr_code.translated_text
  end

  defp scrub_text(changeset) when is_map(changeset) do
    if Map.has_key?(changeset.changes, :text) && is_text(changeset),
      do: change(changeset, text: scrub_text(changeset.changes.text)),
      else: changeset
  end

  defp scrub_text(text) when is_bitstring(text) do
    {:ok, scrubbed_text} = Sanitizer.scrub(text, TextScrubber)
    scrubbed_text
  end

  defp is_text(changeset) do
    get_field(changeset, :content_type) == :text
  end

  defp text_length(text, :text) do
    {:ok, stripped_text} = FastSanitize.strip_tags(text)
    String.length(stripped_text)
  end

  defp text_length(text, _) do
    String.length(text)
  end

  defp valid_url?(url) when is_binary(url) do
    # links should have a host and a scheme - this is not covered by uri_new:
    uri_parse =
      case URI.parse(url) do
        %URI{host: nil} ->
          false

        %URI{scheme: nil} ->
          false

        %URI{} ->
          true
      end

    uri_new =
      case URI.new(url) do
        {:ok, _} -> true
        {:error, _} -> false
      end

    uri_parse && uri_new
  end

  defp valid_url?(_), do: false

  defp check_language(changeset) do
    if Enum.member?(@languages, get_field(changeset, :language)),
      do: [],
      else: [{:language, "Audio type requires language"}]
  end

  defp check_voice(changeset) do
    if Enum.member?(@voices, get_field(changeset, :voice)),
      do: [],
      else: [{:voice, "Audio type requires voice"}]
  end

  defp check_block_list(changeset) do
    text = get_field(changeset, :text)

    if String.contains?(text, @block_list),
      do: [{:text, "Text contains content that is not allowed"}],
      else: []
  end
end
