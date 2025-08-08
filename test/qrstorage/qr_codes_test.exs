defmodule Qrstorage.QrCodesTest do
  use Qrstorage.DataCase

  alias Qrstorage.QrCodes

  import ExUnit.CaptureLog

  describe "qrcodes" do
    alias Qrstorage.QrCodes.QrCode

    @valid_attrs %{
      delete_after_months: 1,
      text: "some text",
      hide_text: false,
      content_type: "text",
      language: nil,
      hp: nil,
      deltas: %{"id" => "test"},
      dots_type: "dots"
    }

    @valid_audio_attrs %{
      text: "some text",
      hide_text: false,
      content_type: "audio",
      language: "de",
      hp: nil,
      voice: "female",
      dots_type: "dots"
    }

    @valid_link_attrs %{
      text: "https://kits.blog",
      hide_text: false,
      content_type: "link",
      language: nil,
      hp: nil,
      dots_type: "dots"
    }

    @attrs_without_hide_text %{
      text: "some text",
      content_type: "text",
      dots_type: "dots"
    }
    @invalid_attrs %{delete_after_months: nil, text: nil}

    test "get_qr_code!/1 returns the qr_code with given id" do
      qr_code = qr_code_fixture()
      qr_code_from_database = QrCodes.get_qr_code!(qr_code.id)
      assert qr_code.id == qr_code_from_database.id
      assert qr_code.text == qr_code_from_database.text
    end

    test "create_qr_code/1 with valid data creates a qr_code" do
      assert {:ok, %QrCode{} = qr_code} = QrCodes.create_qr_code(@valid_attrs)
      assert qr_code.delete_after_months == 1
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

    for invalid_url <- [
          "invalid",
          "https://kits.blog\n\r",
          "https://kits.blog/ abc",
          "mailto:example.com",
          "mailto:example@example.com?body=abc;invalid",
          "https://example.com/\"",
          ~s(http://example.com/")
        ] do
      test "create_qr_code/1 with type link and invalid url #{invalid_url} returns error changeset" do
        invalid_link_attrs = %{@valid_link_attrs | text: unquote(invalid_url)}

        assert {:error, %Ecto.Changeset{}} = QrCodes.create_qr_code(invalid_link_attrs)
      end
    end

    test "create_qr_code/1 with type link and valid mailto adress returns ok" do
      valid_link_attrs = %{@valid_link_attrs | text: "mailto:example@example.com&body=test&subject=test"}

      assert {:ok, %QrCode{} = _qr_code} = QrCodes.create_qr_code(valid_link_attrs)
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

    test "create_qr_code/1 with audio longer than 1000 returns error changeset" do
      too_long = String.duplicate("a", 1001)

      invalid_audio_attrs = %{
        @valid_audio_attrs
        | text: too_long
      }

      assert {:error, %Ecto.Changeset{}} = QrCodes.create_qr_code(invalid_audio_attrs)
    end

    test "create_qr_code/1 with audio with length of 1000 returns ok" do
      correct_length = String.duplicate("a", 1000)

      valid_audio_attrs = %{
        @valid_audio_attrs
        | text: correct_length
      }

      assert {:ok, %QrCode{} = _qr_code} = QrCodes.create_qr_code(valid_audio_attrs)
    end

    test "create_qr_code/1 with text longer than 4000 returns error changeset" do
      too_long = String.duplicate("a", 4001)
      invalid_text_attrs = %{@valid_attrs | content_type: "text", text: too_long}

      assert {:error, %Ecto.Changeset{}} = QrCodes.create_qr_code(invalid_text_attrs)
    end

    test "create_qr_code/1 with text equal 4000 characters excluding tags returns ok" do
      correct_length = String.duplicate("<a>a</a>", 4000)
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
      overdue_qr_code = overdue_qr_code()
      active_qr_code = qr_code_fixture()

      {deleted_count, [deleted_code]} = QrCodes.delete_old_qr_codes()

      # only the overdue qr code is deleted:
      assert deleted_count == 1
      assert deleted_code.id == overdue_qr_code.id
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

  describe "audio_character_count_in_last_hours/1" do
    test "audio_character_count_in_last_hours/1 without existing audio codes returns 0" do
      {result, logs} = with_log(fn -> QrCodes.audio_character_count_in_last_hours(1) end)

      assert result == 0
      assert logs =~ "Character length for audio characters is nil"
    end

    test "audio_character_count_in_last_hours/1 with multiple codes return correct value" do
      qr_code_with_insertion_date(@valid_audio_attrs, Timex.shift(Timex.now(), hours: -2))
      qr_code_with_insertion_date(@valid_audio_attrs, Timex.shift(Timex.now(), hours: -1))
      QrCodes.create_qr_code(@valid_audio_attrs)

      assert QrCodes.audio_character_count_in_last_hours(3) == String.length(@valid_audio_attrs.text) * 3
      assert QrCodes.audio_character_count_in_last_hours(2) == String.length(@valid_audio_attrs.text) * 2
      assert QrCodes.audio_character_count_in_last_hours(1) == String.length(@valid_audio_attrs.text)
    end

    test "audio_character_count_in_last_hours/1 only counts audio codes" do
      qr_code_with_insertion_date(@valid_audio_attrs, Timex.shift(Timex.now(), hours: -1))
      qr_code_with_insertion_date(@valid_link_attrs, Timex.shift(Timex.now(), hours: -1))
      qr_code_with_insertion_date(@valid_attrs, Timex.shift(Timex.now(), hours: -1))

      assert QrCodes.audio_character_count_in_last_hours(2) == String.length(@valid_audio_attrs.text)
    end
  end
end
