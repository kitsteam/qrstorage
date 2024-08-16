defmodule Qrstorage.Services.TranslationServiceTest do
  use Qrstorage.DataCase

  alias Qrstorage.Services.TranslationService
  alias Qrstorage.QrCodes

  import Mox
  setup :verify_on_exit!
  import ExUnit.CaptureLog

  defp create_audio_qr_code(_) do
    %{qr_code: audio_qr_code_fixture()}
  end

  describe "add_translation/1 without audio code" do
    test "add_translation/1 with a text code returns :error" do
      qr_code = qr_code_fixture(%{content_type: "text"})

      {result, _log} =
        with_log(fn -> TranslationService.add_translation(qr_code) end)

      assert result == {:error, "Qr code translation failed."}
    end

    test "text_to_audio/1 with a link code returns :error" do
      qr_code = qr_code_fixture(%{content_type: "link", text: "https://kits.blog"})

      {result, _log} =
        with_log(fn -> TranslationService.add_translation(qr_code) end)

      assert result == {:error, "Qr code translation failed."}
    end
  end

  describe "add_translation/1 with audio code" do
    setup [:create_audio_qr_code]

    test "add_translation/1 with an audio code adds translated text", %{qr_code: qr_code} do
      Qrstorage.Services.Translate.TranslateApiServiceMock
      |> expect(:translate, fn _text, _language ->
        {:ok, "translated text"}
      end)

      {:ok, translated_qr_code} = TranslationService.add_translation(qr_code)

      assert translated_qr_code.translated_text == "translated text"
    end

    test "add_translation/1 without language returns :error", %{qr_code: qr_code} do
      qr_code = %{qr_code | language: nil}

      {status, _log} =
        with_log(fn ->
          TranslationService.add_translation(qr_code) |> elem(0)
        end)

      assert status == :error
    end

    test "add_translation/1 with broken TranslateApiServiceMock returns :error", %{qr_code: qr_code} do
      Qrstorage.Services.Translate.TranslateApiServiceMock
      |> expect(:translate, fn _text, _language ->
        {:error}
      end)

      {result, log} =
        with_log(fn ->
          TranslationService.add_translation(qr_code)
        end)

      assert result == {:error, "Qr code translation failed."}
      assert log =~ "Text not translated"
    end
  end
end
