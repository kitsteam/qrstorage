defmodule QrstorageWeb.QrCodeView do
  use QrstorageWeb, :view
  alias Qrstorage.QrCodes.QrCode

  alias HtmlSanitizeEx.Scrubber
  alias Qrstorage.Scrubber.TextScrubber

  def content_group_checked(changeset, content_group) do
    # Without changes, we default to show the content group of the type link:
    if changeset.changes == %{} do
      case content_group do
        "link" -> true
        _ -> false
      end
    else
      to_string(changeset.changes.content_type) == content_group
    end
  end

  def changeset_for_content_type(changeset, content_type) do
    # When the changeset is empty, we can just return this.
    # When it's set, we only want to return it for the correct content type:
    if changeset.changes == %{} || to_string(changeset.changes.content_type) == content_type do
      changeset
    else
      %QrCode{}
      |> QrCode.changeset(%{})
    end
  end

  def sanitize(text) do
    Scrubber.scrub(text, TextScrubber)
  end

  def deltas_json_from_changeset(changeset) do
    deltas = Map.get(changeset.changes, :deltas, "")

    case JSON.encode(deltas) do
      {:ok, json} -> json
      _ -> ""
    end
  end

  def show_delete_after_text(delete_after) do
    if delete_after.year == QrCode.max_delete_after_year() do
      gettext("This qr code will be stored indefinitely.")
    else
      Timex.format!(delete_after, "{relative}", :relative)
    end
  end

  def dots_type_checked?(dots_type, changeset) do
    if changeset.changes == %{} || get_in(changeset.changes, [:dots_type]) == nil do
      # return true for default/first dots_type when changeset is empty or dots_type is nil
      dots_type == QrCode.default_dots_type()
    else
      changeset.changes.dots_type == dots_type
    end
  end
end
