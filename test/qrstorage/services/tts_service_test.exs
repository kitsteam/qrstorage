defmodule Qrstorage.Services.TtsServiceTest do
  use ExUnit.Case, async: true

  alias Qrstorage.Services.TtsService
  alias Qrstorage.QrCodes
  alias Qrstorage.QrCodes.QrCode
  alias Qrstorage.Repo

  import Mox
  import ExUnit.CaptureLog

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

      assert TtsService.text_to_audio(qr_code) |> elem(0) == :ok
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

      {:ok, updated_qr_code} = TtsService.text_to_audio(qr_code)
      assert updated_qr_code.audio_file == "string"
      assert updated_qr_code.audio_file_type == "audio/mp3"
    end

    test "text_to_audio/1 with translated text uses translated text for audio", %{
      qr_code: qr_code
    } do
      # add translation:
      translated_text = "some translated text"

      qr_code =
        QrCode.changeset_with_translated_text(
          qr_code,
          %{"translated_text" => translated_text}
        )
        |> Repo.update!()

      Qrstorage.Services.Gcp.GoogleApiServiceMock
      |> expect(:text_to_audio, fn text, _language, _voice ->
        assert qr_code.text != text
        assert qr_code.translated_text == text

        {:ok, "string"}
      end)

      {:ok, updated_qr_code} = TtsService.text_to_audio(qr_code)
      assert updated_qr_code.audio_file == "string"
    end

    test "text_to_audio/1 with broken GoogleApiServiceMock returns :error", %{qr_code: qr_code} do
      Qrstorage.Services.Gcp.GoogleApiServiceMock
      |> expect(:text_to_audio, fn _text, _language, _voice ->
        {:error}
      end)

      {result, log} =
        with_log(fn ->
          TtsService.text_to_audio(qr_code)
        end)

      assert result == {:error, qr_code}
      assert log =~ "Text not transcribed"
    end
  end
end
