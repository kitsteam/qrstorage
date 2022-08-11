defmodule Qrstorage.Services.TtsServiceTest do
  use ExUnit.Case, async: true

  alias Qrstorage.Services.TtsService
  alias Qrstorage.QrCodes

  import Mox

  @valid_attrs %{
    delete_after: ~D[2010-04-17],
    text: "t",
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

  describe "text_to_audio/1 without audio code" do
    test "text_to_audio/1 with a text code returns :no_audio_type" do
      qr_code = qr_code_fixture(%{content_type: "text"})

      assert TtsService.text_to_audio(qr_code) == {:no_audio_type}
    end

    test "text_to_audio/1 with a link code returns :no_audio_type" do
      qr_code = qr_code_fixture(%{content_type: "link", text: "https://kits.blog"})

      assert TtsService.text_to_audio(qr_code) == {:no_audio_type}
    end
  end

  describe "text_to_audio/1 with audio code" do
    setup [:create_audio_qr_code]

    test "text_to_audio/1 with an audio code returns :ok", %{qr_code: qr_code} do
      Qrstorage.Services.Gcp.GoogleApiServiceMock
      |> expect(:text_to_audio, fn _text, _language, _voice ->
        {:ok, "string"}
      end)

      assert TtsService.text_to_audio(qr_code) == {:ok}
    end

    test "text_to_audio/1 with an audio code passes correct values", %{qr_code: qr_code} do
      Qrstorage.Services.Gcp.GoogleApiServiceMock
      |> expect(:text_to_audio, fn text, language, voice ->
        assert qr_code.text == text
        assert qr_code.language == language
        assert Atom.to_string(qr_code.voice) == voice

        {:ok, "string"}
      end)
    end

    test "text_to_audio/1 saves response from api", %{qr_code: qr_code} do
      Qrstorage.Services.Gcp.GoogleApiServiceMock
      |> expect(:text_to_audio, fn _text, _language, _voice ->
        {:ok, "string"}
      end)

      assert TtsService.text_to_audio(qr_code) == {:ok}
      qr_code = QrCodes.get_qr_code!(qr_code.id)
      assert qr_code.audio_file == "string"
      assert qr_code.audio_file_type == "audio/mp3"
    end
  end
end
