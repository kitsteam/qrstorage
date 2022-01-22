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
end
