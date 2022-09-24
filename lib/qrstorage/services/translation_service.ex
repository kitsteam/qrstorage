defmodule Qrstorage.Services.TranslationService do
  alias Qrstorage.QrCodes.QrCode
  alias Qrstorage.Repo
  alias Qrstorage.Services.Gcp.GoogleApiService

  require Logger

  # we need a language, otherwise we don't know into which language to translate
  def add_translation(qr_code) when qr_code.language == :none do
    {:no_language}
  end

  # translation is only meant for audio qr codes:
  def add_translation(qr_code) when qr_code.content_type != :audio do
    {:no_audio_type}
  end

  def add_translation(qr_code) do
    case GoogleApiService.translate(qr_code.text, qr_code.language) do
      {:ok, translated_text} ->
        save_translated_text(qr_code, translated_text)

      {:error} ->
        Logger.warn("Text not translated for qr_code id: #{qr_code.id}")
        {:error, qr_code}
    end
  end

  defp save_translated_text(qr_code, translated_text) do
    qr_code_with_translation =
      QrCode.changeset_with_translated_text(
        qr_code,
        %{"translated_text" => translated_text}
      )
      |> Repo.update!()

    {:ok, qr_code_with_translation}
  end
end
