defmodule Qrstorage.Services.TtsService do
  alias Qrstorage.QrCodes.QrCode
  alias Qrstorage.Repo
  alias Qrstorage.Services.Gcp.GoogleApiService

  require Logger

  def text_to_audio(qr_code) when qr_code.language == :none do
    {:no_language}
  end

  def text_to_audio(qr_code) when qr_code.content_type != :audio do
    {:no_audio_type}
  end

  def text_to_audio(qr_code) do
    text = text_for_audio_transcription(qr_code)

    case GoogleApiService.text_to_audio(
           text,
           qr_code.language,
           Atom.to_string(qr_code.voice)
         ) do
      {:ok, audio_file} ->
        store_audio_file(qr_code, audio_file)

      {:error} ->
        Logger.warn("Text not transcribed for qr_code id: #{qr_code.id}")
        {:error, qr_code}
    end
  end

  def text_for_audio_transcription(qr_code) do
    qr_code.translated_text || qr_code.text
  end

  def store_audio_file(qr_code, audio_file) do
    qr_code_with_audio =
      QrCode.store_audio_file(
        qr_code,
        %{"audio_file" => audio_file, "audio_file_type" => "audio/mp3"}
      )
      |> Repo.update!()

    {:ok, qr_code_with_audio}
  end
end
