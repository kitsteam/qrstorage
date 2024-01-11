defmodule Qrstorage.Services.Gcp.GoogleApiServiceImpl do
  alias Qrstorage.Services.Gcp.GoogleApiService
  alias Qrstorage.Services.Gcp.GoogleTtsVoices

  @behaviour GoogleApiService

  require Logger

  @impl GoogleApiService
  def text_to_audio(text, language, voice) do
    request = build_synthesize_speech_request(text, language, voice)
    response_body = ""

    # ::TODO:: refactor - this isn't really the elixir way
    try do
      {:ok, response} =
        GoogleApi.TextToSpeech.V1.Api.Text.texttospeech_text_synthesize(authenticated_connection(),
          body: request
        )

      ^response_body = response.audioContent
    rescue
      _e -> Logger.info("Exception caught while getting audio")
    end

    decoded_file = Base.decode64!(response_body)
    {:ok, decoded_file}
  end

  @impl GoogleApiService
  def translate(text, target_language) do
    # https://hexdocs.pm/google_api_translate/GoogleApi.Translate.V2.Api.Translations.html#language_translations_list/5
    translated_text = ""

    # ::TODO:: refactor - this isn't really the elixir way
    try do
      {:ok, response} =
        GoogleApi.Translate.V2.Api.Translations.language_translations_list(
          authenticated_connection(),
          [text],
          target_language,
          format: "text"
        )

      ^translated_text = List.first(response.translations).translatedText
    rescue
      _e -> Logger.info("Exception caught while translating text")
    end

    {:ok, translated_text}
  end

  def build_synthesize_speech_request(text, language, gender) do
    %GoogleApi.TextToSpeech.V1.Model.SynthesizeSpeechRequest{
      audioConfig: %GoogleApi.TextToSpeech.V1.Model.AudioConfig{
        audioEncoding: "MP3"
      },
      input: %GoogleApi.TextToSpeech.V1.Model.SynthesisInput{
        text: text
      },
      voice: %GoogleApi.TextToSpeech.V1.Model.VoiceSelectionParams{
        languageCode: Atom.to_string(language || :de),
        name: GoogleTtsVoices.voice(language, gender),
        ssmlGender: gender || "female"
      }
    }
  end

  defp authenticated_connection() do
    # Authentication
    {:ok, token} = Goth.fetch(Qrstorage.Goth)
    GoogleApi.Translate.V2.Connection.new(token.token)
  end
end
