defmodule QrstorageWeb.QrCodeView do
  use QrstorageWeb, :view
  alias Qrstorage.QrCodes.QrCode

  alias FastSanitize.Sanitizer
  alias Qrstorage.Scrubber.TextScrubber

  def content_group_checked(changeset, content_group) do
    # Without changes, we default to show the content group of the type audio:
    if changeset.changes == %{} do
      case content_group do
        "audio" -> true
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

    case Jason.encode(deltas) do
      {:ok, json} -> json
      _ -> ""
    end
  end

  def show_delete_after_text(qr_code) do
    Timex.format!(deletion_date(qr_code), "{relative}", :relative)
  end

  def deletion_date(qr_code) do
    Timex.shift(qr_code.last_accessed_at, months: qr_code.delete_after_months)
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

  def before_translation_transition(qr_code) do
    {:ok, translation_transition_date} =
      NaiveDateTime.from_iso8601(Application.get_env(:qrstorage, :translation_transition_date))

    NaiveDateTime.before?(qr_code.inserted_at, translation_transition_date)
  end

  def show_translation_origin_for_hidden_text(qr_code) do
    # we show the translation origin when the code has been created before the transition and the text box is not already shown
    QrCode.translation_changed_text(qr_code) && qr_code.hide_text && before_translation_transition(qr_code)
  end
end
