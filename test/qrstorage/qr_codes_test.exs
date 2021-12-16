defmodule Qrstorage.QrCodesTest do
  use Qrstorage.DataCase

  alias Qrstorage.QrCodes

  describe "qrcodes" do
    alias Qrstorage.QrCodes.QrCode

    @valid_attrs %{
      delete_after: ~D[2010-04-17],
      text: "some text",
      hide_text: false,
      content_type: "text",
      language: nil
    }
    @attrs_without_hide_text %{
      delete_after: ~D[2010-04-17],
      text: "some text",
      content_type: "text"
    }
    @invalid_attrs %{delete_after: nil, text: nil}

    def qr_code_fixture(attrs \\ %{}) do
      {:ok, qr_code} =
        attrs
        |> Enum.into(@valid_attrs)
        |> QrCodes.create_qr_code()

      qr_code
    end

    test "get_qr_code!/1 returns the qr_code with given id" do
      qr_code = qr_code_fixture()
      assert QrCodes.get_qr_code!(qr_code.id) == qr_code
    end

    test "create_qr_code/1 with valid data creates a qr_code" do
      assert {:ok, %QrCode{} = qr_code} = QrCodes.create_qr_code(@valid_attrs)
      assert qr_code.delete_after == ~D[2010-04-17]
      assert qr_code.text == "some text"
      assert qr_code.hide_text == false
    end

    test "create_qr_code/1 defaults to hide text" do
      assert {:ok, %QrCode{} = qr_code} = QrCodes.create_qr_code(@attrs_without_hide_text)
      assert qr_code.hide_text == true
    end

    test "create_qr_code/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = QrCodes.create_qr_code(@invalid_attrs)
    end

    test "create_qr_code/1 with type link and invalid url returns error changeset" do
      invalid_link_attrs = %{@valid_attrs | content_type: "link", text: "invalid"}

      assert {:error, %Ecto.Changeset{}} = QrCodes.create_qr_code(invalid_link_attrs)
    end

    test "create_qr_code/1 with type link and valid url returns ok" do
      valid_link_attrs = %{@valid_attrs | content_type: "link", text: "https://kits.blog"}

      assert {:ok, %QrCode{} = _qr_code} = QrCodes.create_qr_code(valid_link_attrs)
    end

    test "create_qr_code/1 with audio but without language returns error changeset" do
      invalid_link_attrs = %{@valid_attrs | content_type: "audio", language: nil}

      assert {:error, %Ecto.Changeset{}} = QrCodes.create_qr_code(invalid_link_attrs)
    end

    test "create_qr_code/1 with audio and with language returns ok" do
      valid_link_attrs = %{@valid_attrs | content_type: "audio", language: "de"}

      assert {:ok, %QrCode{} = _qr_code} = QrCodes.create_qr_code(valid_link_attrs)
    end
  end
end
