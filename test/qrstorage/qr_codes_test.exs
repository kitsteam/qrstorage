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
      language: nil,
      hp: nil,
      deltas: %{"id" => "test"},
      dots_type: "dots"
    }

    @valid_audio_attrs %{
      delete_after: ~D[2010-04-17],
      text: "some text",
      hide_text: false,
      content_type: "audio",
      language: "de",
      hp: nil,
      voice: "female",
      dots_type: "dots"
    }

    @valid_link_attrs %{
      delete_after: ~D[2010-04-17],
      text: "https://kits.blog",
      hide_text: false,
      content_type: "link",
      language: nil,
      hp: nil,
      dots_type: "dots"
    }

    @attrs_without_hide_text %{
      delete_after: ~D[2010-04-17],
      text: "some text",
      content_type: "text",
      dots_type: "dots"
    }
    @invalid_attrs %{delete_after: nil, text: nil}

    def qr_code_fixture(attrs \\ %{}) do
      {:ok, qr_code} =
        attrs
        |> Enum.into(@valid_attrs)
        |> QrCodes.create_qr_code()

      qr_code
    end

    def infinity_qr_code() do
      attrs = %{@valid_attrs | delete_after: Timex.end_of_year(QrCode.max_delete_after_year())}
      qr_code_fixture(attrs)
    end

    def overdue_qr_code() do
      attrs = %{@valid_attrs | delete_after: Timex.shift(Timex.now(), months: -5)}
      qr_code_fixture(attrs)
    end

    def active_qr_code() do
      attrs = %{@valid_attrs | delete_after: Timex.shift(Timex.now(), months: 5)}
      qr_code_fixture(attrs)
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
      invalid_link_attrs = %{@valid_link_attrs | text: "invalid"}

      assert {:error, %Ecto.Changeset{}} = QrCodes.create_qr_code(invalid_link_attrs)
    end

    test "create_qr_code/1 with type link and invalid url with line break returns error changeset" do
      invalid_link_attrs = %{@valid_link_attrs | text: "https://kits.blog\n\r"}

      assert {:error, %Ecto.Changeset{}} = QrCodes.create_qr_code(invalid_link_attrs)
    end

    test "create_qr_code/1 with type link and invalid url with white spaces returns error changeset" do
      invalid_link_attrs = %{@valid_link_attrs | text: "https://kits.blog/ abc"}

      assert {:error, %Ecto.Changeset{}} = QrCodes.create_qr_code(invalid_link_attrs)
    end

    test "create_qr_code/1 with type link and valid url returns ok" do
      valid_link_attrs = %{@valid_link_attrs | text: "https://kits.blog"}

      assert {:ok, %QrCode{} = _qr_code} = QrCodes.create_qr_code(valid_link_attrs)
    end

    test "create_qr_code/1 with link with uppercase letters is valid" do
      valid_link_attrs = %{@valid_link_attrs | text: "HTTPS://KITS.blog"}

      assert {:ok, %QrCode{} = _qr_code} = QrCodes.create_qr_code(valid_link_attrs)
    end

    test "create_qr_code/1 with audio but without language returns error changeset" do
      invalid_audio_attrs = %{@valid_audio_attrs | language: nil}

      assert {:error, %Ecto.Changeset{}} = QrCodes.create_qr_code(invalid_audio_attrs)
    end

    test "create_qr_code/1 with valid audio attributes returns ok" do
      assert {:ok, %QrCode{} = _qr_code} = QrCodes.create_qr_code(@valid_audio_attrs)
    end

    test "create_qr_code/1 with audio but without voice returns error changeset" do
      invalid_audio_attrs = %{@valid_audio_attrs | voice: nil}

      assert {:error, %Ecto.Changeset{}} = QrCodes.create_qr_code(invalid_audio_attrs)
    end

    test "create_qr_code/1 with link longer than 1500 returns error changeset" do
      too_long = String.duplicate("a", 1501)

      invalid_link_attrs = %{
        @valid_attrs
        | content_type: "link",
          text: "https://kits.blog/?#{too_long}"
      }

      assert {:error, %Ecto.Changeset{}} = QrCodes.create_qr_code(invalid_link_attrs)
    end

    test "create_qr_code/1 with audio longer than 2000 returns error changeset" do
      too_long = String.duplicate("a", 2001)

      invalid_audio_attrs = %{
        @valid_audio_attrs
        | text: too_long
      }

      assert {:error, %Ecto.Changeset{}} = QrCodes.create_qr_code(invalid_audio_attrs)
    end

    test "create_qr_code/1 with audio with length of 2000 returns ok" do
      correct_length = String.duplicate("a", 2000)

      valid_audio_attrs = %{
        @valid_audio_attrs
        | text: correct_length
      }

      assert {:ok, %QrCode{} = _qr_code} = QrCodes.create_qr_code(valid_audio_attrs)
    end

    test "create_qr_code/1 with text longer than 2000 returns error changeset" do
      too_long = String.duplicate("a", 2001)
      invalid_text_attrs = %{@valid_attrs | content_type: "text", text: too_long}

      assert {:error, %Ecto.Changeset{}} = QrCodes.create_qr_code(invalid_text_attrs)
    end

    test "create_qr_code/1 with text equal 2000 characters excluding tags returns ok" do
      correct_length = String.duplicate("<a>a</a>", 2000)
      valid_text_attrs = %{@valid_attrs | content_type: "text", text: correct_length}

      assert {:ok, %QrCode{} = _qr_code} = QrCodes.create_qr_code(valid_text_attrs)
    end

    test "create_qr_code/1 with audio that has content on blocklist returns error changeset" do
      invalid_audio_attrs = %{@valid_audio_attrs | text: "We dont allow https"}
      assert {:error, %Ecto.Changeset{}} = QrCodes.create_qr_code(invalid_audio_attrs)

      invalid_audio_attrs = %{@valid_audio_attrs | text: "We dont allow http"}
      assert {:error, %Ecto.Changeset{}} = QrCodes.create_qr_code(invalid_audio_attrs)
    end

    test "qrcodes have an admin url id after creation" do
      assert {:ok, %QrCode{} = qr_code} = QrCodes.create_qr_code(@valid_attrs)
      assert qr_code.admin_url_id != nil
    end

    test "delete_old_qr_codes/0 deletes qr codes older than their delete_after date" do
      infinity_qr_code = infinity_qr_code()
      overdue_qr_code = overdue_qr_code()
      active_qr_code = active_qr_code()

      deleted_count = QrCodes.delete_old_qr_codes()

      # only the overdue qr code is deleted:
      assert deleted_count == 1
      assert Repo.get(QrCode, infinity_qr_code.id) != nil
      assert Repo.get(QrCode, overdue_qr_code.id) == nil
      assert Repo.get(QrCode, active_qr_code.id) != nil
    end

    test "create_qr_code/1 with invalid dots_type returns error changeset" do
      invalid_attrs = %{@valid_attrs | dots_type: "invalid"}
      assert {:error, %Ecto.Changeset{}} = QrCodes.create_qr_code(invalid_attrs)
    end

    test "create_qr_code/1 without dots_type returns error changeset" do
      invalid_attrs = %{@valid_attrs | dots_type: ""}
      assert {:error, %Ecto.Changeset{}} = QrCodes.create_qr_code(invalid_attrs)
    end
  end

  describe "honeypot" do
    test "create_qr_code/1 with audio type and honeypot set returns error changeset" do
      invalid_audio_attrs = %{@valid_audio_attrs | hp: "set"}
      assert {:error, %Ecto.Changeset{}} = QrCodes.create_qr_code(invalid_audio_attrs)
    end

    test "create_qr_code/1 with link type and honeypot set returns error changeset" do
      invalid_link_attrs = %{@valid_link_attrs | hp: "set"}
      assert {:error, %Ecto.Changeset{}} = QrCodes.create_qr_code(invalid_link_attrs)
    end

    test "create_qr_code/1 with text type and honeypot set returns error changeset" do
      invalid_text_attrs = %{@valid_attrs | hp: "set"}
      assert {:error, %Ecto.Changeset{}} = QrCodes.create_qr_code(invalid_text_attrs)
    end
  end
end
