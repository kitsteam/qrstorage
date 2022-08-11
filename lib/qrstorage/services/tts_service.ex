defmodule Qrstorage.Services.TtsService do
  alias Qrstorage.QrCodes.QrCode
  alias Qrstorage.Repo
  alias Qrstorage.Services.Gcp.GoogleApiService

  def text_to_audio(qr_code) when qr_code.language == :none do
    {:no_language}
  end

  def text_to_audio(qr_code) when qr_code.content_type != :audio do
    {:no_audio_type}
  end

  def text_to_audio(qr_code) do
    case GoogleApiService.text_to_audio(
           qr_code.text,
           qr_code.language,
           Atom.to_string(qr_code.voice)
         ) do
      {:ok, audio_file} -> store_audio_file(qr_code, audio_file)
      {:error} -> {:error}
    end
  end

  def store_audio_file(qr_code, audio_file) do
    QrCode.store_audio_file(
      qr_code,
      %{"audio_file" => audio_file, "audio_file_type" => "audio/mp3"}
    )
    |> Repo.update!()

    {:ok}
  end
end
