defmodule Qrstorage.QrCodes.QrCodeTest do
  use Qrstorage.DataCase

  alias Qrstorage.QrCodes.QrCode

  @qr_code %QrCode{text: "Hello", translated_text: "Hello"}

  describe "translation_changed_text/1" do
    test "returns false when the translation is not different from user entry" do
      assert !QrCode.translation_changed_text(@qr_code)
    end

    test "returns true when the translation is different from user entry" do
      translated_qr_code = %{@qr_code | translated_text: "Hallo"}
      assert QrCode.translation_changed_text(translated_qr_code)
    end
  end
end
