defmodule Qrstorage.QrCodesRecordingTest do
  use Qrstorage.DataCase

  alias Qrstorage.QrCodes

  describe "recrding qrcodes" do
    alias Qrstorage.QrCodes.QrCode

    @valid_recording_attrs %{
      text: "-",
      delete_after: ~D[2010-04-17],
      content_type: "recording",
      hp: nil,
      dots_type: "dots"
    }

    test "create_qr_code/1 with valid data creates a recording qr_code" do
      # This is a very simple check, as we currently allow recordings to be empty. We store them first, and add the audio files afterwards. This would be impossible if we required them on creation
      assert {:ok, %QrCode{} = qr_code} = QrCodes.create_qr_code(@valid_recording_attrs)
      assert qr_code.text == "-"
    end

    test "create_qr_code/1 with invalid data returns error changeset" do
      invalid_attrs = %{@valid_recording_attrs | text: "-------"}
      assert {:error, %Ecto.Changeset{}} = QrCodes.create_qr_code(invalid_attrs)
    end
  end
end
