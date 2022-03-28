defmodule QrstorageWeb.QrCodeViewTest do
  use QrstorageWeb.ConnCase, async: true

  import QrstorageWeb.QrCodeView
  alias Qrstorage.QrCodes.QrCode

  test "renders deltas as json string" do
    changeset = %{changes: %{deltas: %{ops: "test"}}}
    assert deltas_json_from_changeset(changeset) == "{\"ops\":\"test\"}"
  end

  test "returns empty json string without deltas" do
    changeset = %{changes: %{}}
    assert deltas_json_from_changeset(changeset) == "\"\""
  end

  test "shows indefinitely for qr codes that should not be automatically deleted" do
    delete_after = Timex.end_of_year(QrCode.max_delete_after_year())
    text = show_delete_after_text(delete_after)
    assert text =~ "indefinitely"
  end

  test "shows relative deletion date for qr codes that should be deleted automatically" do
    delete_after = Timex.shift(Timex.now(), months: 5)
    text = show_delete_after_text(delete_after)
    assert text =~ "in 5 months"
  end
end
