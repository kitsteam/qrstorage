defmodule Qrstorage.Services.Gcp.GoogleApiServiceImpl do
  alias Qrstorage.Services.Gcp.GoogleApiService

  @behaviour GoogleApiService

  @impl GoogleApiService
  def text_to_audio(text, language, voice) do
    request = build_synthesize_speech_request(text, language, voice)

    # Authentication
    {:ok, token} = Goth.Token.for_scope("https://www.googleapis.com/auth/cloud-platform")
    connection = GoogleApi.TextToSpeech.V1.Connection.new(token.token)

    {:ok, response} =
      GoogleApi.TextToSpeech.V1.Api.Text.texttospeech_text_synthesize(connection, body: request)

    decoded_file = Base.decode64!(response.audioContent)
    {:ok, decoded_file}
  end

  def build_synthesize_speech_request(text, language, voice) do
    %GoogleApi.TextToSpeech.V1.Model.SynthesizeSpeechRequest{
      audioConfig: %GoogleApi.TextToSpeech.V1.Model.AudioConfig{
        audioEncoding: "MP3"
      },
      input: %GoogleApi.TextToSpeech.V1.Model.SynthesisInput{
        text: text
      },
      voice: %GoogleApi.TextToSpeech.V1.Model.VoiceSelectionParams{
        languageCode: language || "de",
        ssmlGender: voice || "female"
      }
    }
  end
end
