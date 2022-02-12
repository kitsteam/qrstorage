defmodule QrstorageWeb.QrCodeViewTest do
  use QrstorageWeb.ConnCase, async: true

  import QrstorageWeb.QrCodeView

  test "renders deltas as json string" do
    changeset = %{changes: %{deltas: %{ops: "test"}}}
    assert deltas_json_from_changeset(changeset) == "{\"ops\":\"test\"}"
  end

  test "returns empty json string without deltas" do
    changeset = %{changes: %{}}
    assert deltas_json_from_changeset(changeset) == "\"\""
  end
end
