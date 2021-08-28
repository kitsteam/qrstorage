defmodule Qrstorage.TtsService do
  alias Qrstorage.QrCodes.QrCode
  alias Qrstorage.Repo

  def text_to_audio(qr_code) when qr_code.language == :none do
    {:no_language}
  end

  def text_to_audio(qr_code) do
    request = %GoogleApi.TextToSpeech.V1.Model.SynthesizeSpeechRequest{
      audioConfig: %GoogleApi.TextToSpeech.V1.Model.AudioConfig{
        audioEncoding: "MP3"
      },
      input: %GoogleApi.TextToSpeech.V1.Model.SynthesisInput{
        text: qr_code.text
      },
      voice: %GoogleApi.TextToSpeech.V1.Model.VoiceSelectionParams{
        languageCode: qr_code.language || "de",
        ssmlGender:
          System.get_env("GCP_CONFIG_VOICE_GENDER") ||
            "FEMALE"
      }
    }

    # Authentication
    {:ok, token} = Goth.Token.for_scope("https://www.googleapis.com/auth/cloud-platform")
    connection = GoogleApi.TextToSpeech.V1.Connection.new(token.token)

    {:ok, response} =
      GoogleApi.TextToSpeech.V1.Api.Text.texttospeech_text_synthesize(connection, body: request)

    decoded_file = Base.decode64!(response.audioContent)

    QrCode.store_audio_file(
      qr_code,
      %{"audio_file" => decoded_file, "audio_file_type" => "audio/mp3"}
    )
    |> Repo.update!()

    {:ok}
  end
end
