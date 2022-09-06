defmodule Qrstorage.Services.TranslationServiceTest do
  use ExUnit.Case, async: true

  alias Qrstorage.Services.TranslationService
  alias Qrstorage.QrCodes

  import Mox

  @valid_attrs %{
    delete_after: ~D[2010-04-17],
    text: "text",
    content_type: "audio",
    language: "de",
    dots_type: "dots",
    voice: "female"
  }

  def qr_code_fixture(attrs \\ %{}) do
    {:ok, qr_code} =
      attrs
      |> Enum.into(@valid_attrs)
      |> QrCodes.create_qr_code()

    qr_code
  end

  defp create_audio_qr_code(_) do
    %{qr_code: qr_code_fixture()}
  end

  describe "add_translation/1 without audio code" do
    test "add_translation/1 with a text code returns :no_audio_type" do
      qr_code = qr_code_fixture(%{content_type: "text"})

      assert TranslationService.add_translation(qr_code) == {:no_audio_type}
    end

    test "text_to_audio/1 with a link code returns :no_audio_type" do
      qr_code = qr_code_fixture(%{content_type: "link", text: "https://kits.blog"})

      assert TranslationService.add_translation(qr_code) == {:no_audio_type}
    end
  end

  describe "add_translation/1 with audio code" do
    setup [:create_audio_qr_code]


    test "add_translation/1 with an audio code adds translated text", %{qr_code: qr_code} do
      Qrstorage.Services.Gcp.GoogleApiServiceMock
      |> expect(:translate, fn _text, _language ->
        {:ok, "translated text"}
      end)

      {:ok, translated_qr_code} = TranslationService.add_translation(qr_code)

      assert translated_qr_code.translated_text == "translated text"
    end
  end
end
