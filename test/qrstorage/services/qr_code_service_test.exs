defmodule Qrstorage.Services.QrCodeServiceTEst do
  use Qrstorage.DataCase

  alias Qrstorage.Services.QrCodeService

  @create_attrs %{
    "delete_after" => "10",
    "text" => "some text",
    "deltas" => "{\"ops\":[{\"insert\":\"Assad\\n\"}]}",
    "language" => nil,
    "content_type" => "text",
    "dots_type" => "dots",
    "voice" => nil,
    "hp" => nil
  }

  describe "create_qr_code/1" do
    test "create_qr_code/1 returns :ok when the code has been created successfully" do
      {:ok, qr_code} = QrCodeService.create_qr_code(@create_attrs)
      assert qr_code.text == "some text"
    end

    test "create_qrcode/1 returns :error, when the qr code cannot be created" do
      invalid_attrs = %{@create_attrs | "text" => ""}

      {:error, changeset} = QrCodeService.create_qr_code(invalid_attrs)
      assert "can't be blank" in errors_on(changeset).text
    end
  end
end
