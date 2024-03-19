defmodule QrstorageWeb.QrCodeViewTest do
  use QrstorageWeb.ConnCase, async: true

  import QrstorageWeb.QrCodeView
  alias Qrstorage.QrCodes.QrCode

  describe "deltas_json_from_changeset/1" do
    test "renders deltas as json string" do
      changeset = %{changes: %{deltas: %{ops: "test"}}}
      assert deltas_json_from_changeset(changeset) == "{\"ops\":\"test\"}"
    end

    test "returns empty json string without deltas" do
      changeset = %{changes: %{}}
      assert deltas_json_from_changeset(changeset) == "\"\""
    end
  end

  describe "show_delete_after_text/1" do
    test "shows relative deletion date for qr codes that should be deleted automatically" do
      # we add one hour, since Timex seems to round down - e.g. 5 months, minus a few milliseconds results in "in 4 months"
      delete_after_code = %QrCode{delete_after_months: 5, last_accessed_at: Timex.now()}
      text = show_delete_after_text(delete_after_code)
      assert text =~ "in 5 months"
    end
  end

  describe "dots_type_checked?/2" do
    test "returns true when changeset is empty and the dots_type is the default dots_type" do
      changeset = %{changes: %{}}
      dots_type = QrCode.default_dots_type()
      assert dots_type_checked?(dots_type, changeset)
    end

    test "returns false when changeset is empty and the dots_type is not the default dots_type" do
      changeset = %{changes: %{}}
      dots_type = List.last(QrCode.dots_types())
      assert !dots_type_checked?(dots_type, changeset)
    end

    test "returns true when the changeset contains a dots_type and equals the passed dots_type" do
      dots_type = "dots"
      changeset = %{changes: %{dots_type: dots_type}}
      assert dots_type_checked?(dots_type, changeset)
    end

    test "returns false when the changeset contains a dots_type and does not equal the passed dots_type" do
      dots_type = "dots"
      changeset = %{changes: %{dots_type: "square"}}
      assert !dots_type_checked?(dots_type, changeset)
    end
  end

  describe "max_upload_length_message/0" do
    test "returns 2.0 MB for a max_upload_length of 2.6 MB" do
      Application.put_env(:qrstorage, :max_upload_length, "2666666")
      assert max_upload_length_message() =~ "2.0 MB"
    end

    test "returns 2.5 MB for a max_upload_length of 3,3 MB" do
      Application.put_env(:qrstorage, :max_upload_length, "3333333")
      assert max_upload_length_message() =~ "2.5 MB"
    end
  end
end
