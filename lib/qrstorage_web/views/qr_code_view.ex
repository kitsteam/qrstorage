defmodule QrstorageWeb.QrCodeView do
  use QrstorageWeb, :view
  alias Qrstorage.QrCodes.QrCode

  alias FastSanitize.Sanitizer
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

  def scrub(text) do
    {:ok, scrubbed_text} = Sanitizer.scrub(text, TextScrubber)
    scrubbed_text
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

  def max_upload_length_message() do
    # we upload images as base64. The actual image size will be 0.75 of the base64 encoded text.
    # To help the user, we will convert this in the error message.
    # This is not exactly accurate, because a) 0.75 is just an estimation and b) the upload form also takes text characters into account.
    max_upload_length =
      String.to_integer(Application.get_env(:qrstorage, :max_upload_length)) * 0.75

    max_upload_length_in_mb = Decimal.round(Decimal.from_float(max_upload_length * 1.0e-6), 1)

    gettext("The maximum upload size is %{max_length} MB.", max_length: max_upload_length_in_mb)
  end
end
