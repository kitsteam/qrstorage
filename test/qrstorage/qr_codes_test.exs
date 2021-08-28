defmodule Qrstorage.QrCodesTest do
  use Qrstorage.DataCase

  alias Qrstorage.QrCodes

  describe "qrcodes" do
    alias Qrstorage.QrCodes.QrCode

    @valid_attrs %{delete_after: ~D[2010-04-17], text: "some text"}
    @update_attrs %{delete_after: ~D[2011-05-18], text: "some updated text"}
    @invalid_attrs %{delete_after: nil, text: nil}

    def qr_code_fixture(attrs \\ %{}) do
      {:ok, qr_code} =
        attrs
        |> Enum.into(@valid_attrs)
        |> QrCodes.create_qr_code()

      qr_code
    end

    test "list_qrcodes/0 returns all qrcodes" do
      qr_code = qr_code_fixture()
      assert QrCodes.list_qrcodes() == [qr_code]
    end

    test "get_qr_code!/1 returns the qr_code with given id" do
      qr_code = qr_code_fixture()
      assert QrCodes.get_qr_code!(qr_code.id) == qr_code
    end

    test "create_qr_code/1 with valid data creates a qr_code" do
      assert {:ok, %QrCode{} = qr_code} = QrCodes.create_qr_code(@valid_attrs)
      assert qr_code.delete_after == ~D[2010-04-17]
      assert qr_code.text == "some text"
    end

    test "create_qr_code/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = QrCodes.create_qr_code(@invalid_attrs)
    end

    test "update_qr_code/2 with valid data updates the qr_code" do
      qr_code = qr_code_fixture()
      assert {:ok, %QrCode{} = qr_code} = QrCodes.update_qr_code(qr_code, @update_attrs)
      assert qr_code.delete_after == ~D[2011-05-18]
      assert qr_code.text == "some updated text"
    end

    test "update_qr_code/2 with invalid data returns error changeset" do
      qr_code = qr_code_fixture()
      assert {:error, %Ecto.Changeset{}} = QrCodes.update_qr_code(qr_code, @invalid_attrs)
      assert qr_code == QrCodes.get_qr_code!(qr_code.id)
    end

    test "delete_qr_code/1 deletes the qr_code" do
      qr_code = qr_code_fixture()
      assert {:ok, %QrCode{}} = QrCodes.delete_qr_code(qr_code)
      assert_raise Ecto.NoResultsError, fn -> QrCodes.get_qr_code!(qr_code.id) end
    end

    test "change_qr_code/1 returns a qr_code changeset" do
      qr_code = qr_code_fixture()
      assert %Ecto.Changeset{} = QrCodes.change_qr_code(qr_code)
    end
  end
end
