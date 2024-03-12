defmodule Qrstorage.Services.TtsService do
  alias Qrstorage.QrCodes.QrCode
  alias Qrstorage.Repo
  alias Qrstorage.Services.Gcp.GoogleApiService

  import QrstorageWeb.Gettext

  require Logger

  def text_to_audio(%QrCode{} = qr_code) when qr_code.language == :none do
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
        store_audio_file(qr_code, audio_file)

      _ ->
        Logger.warning("Text not transcribed for qr_code id: #{qr_code.id}")
        {:error, gettext("Qr code audio transcription failed.")}
    end
  end

  def text_for_audio_transcription(qr_code) do
    qr_code.translated_text || qr_code.text
  end

  def store_audio_file(%QrCode{} = qr_code, audio_file) when is_binary(audio_file) do
    changeset =
      QrCode.store_audio_file(
        qr_code,
        %{"audio_file" => audio_file, "audio_file_type" => "audio/mp3"}
      )

    case Repo.update(changeset) do
      {:ok, qr_code_with_audio = %QrCode{}} -> {:ok, qr_code_with_audio}
      {:error, changeset_with_errors} -> {:error, changeset_with_errors}
    end
  end
end
