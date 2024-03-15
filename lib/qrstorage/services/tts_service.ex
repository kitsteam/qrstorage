defmodule Qrstorage.Services.TtsService do
  alias Qrstorage.QrCodes.QrCode
  alias Qrstorage.Services.Gcp.GoogleApiService

  import QrstorageWeb.Gettext

  require Logger

  def text_to_audio(%QrCode{} = qr_code) when qr_code.language == :none or qr_code.language == nil do
    Logger.warning("No language for audio qr_code")
    {:error, gettext("Qr code audio transcription failed.")}
  end

  def text_to_audio(%QrCode{} = qr_code) when qr_code.content_type != :audio do
    Logger.warning("TTS called for a qr code without an audio type")
    {:error, gettext("Qr code audio transcription failed.")}
  end

  def text_to_audio(%QrCode{} = qr_code) do
    text = text_for_audio_transcription(qr_code)

    case GoogleApiService.text_to_audio(
           text,
           qr_code.language,
           Atom.to_string(qr_code.voice)
         ) do
      {:ok, audio_file} ->
        {:ok, audio_file, "audio/mp3"}

      _ ->
        Logger.warning("Text not transcribed for qr_code id: #{qr_code.id}")
        {:error, gettext("Qr code audio transcription failed.")}
    end
  end

  def text_for_audio_transcription(qr_code) do
    qr_code.translated_text || qr_code.text
  end
end
