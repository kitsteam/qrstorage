defmodule Qrstorage.Services.Gcp.GoogleApiServiceImplTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog

  alias Qrstorage.Services.Gcp.GoogleApiServiceImpl

  describe "build_synthesize_speech_request/3" do
    test "build_synthesize_speech_request contains text, language and voice" do
      text = "a"
      language = :en
      voice = "female"

      assert GoogleApiServiceImpl.build_synthesize_speech_request(text, language, voice) ==
               %GoogleApi.TextToSpeech.V1.Model.SynthesizeSpeechRequest{
                 audioConfig: %GoogleApi.TextToSpeech.V1.Model.AudioConfig{
                   audioEncoding: "MP3"
                 },
                 input: %GoogleApi.TextToSpeech.V1.Model.SynthesisInput{
                   text: text
                 },
                 voice: %GoogleApi.TextToSpeech.V1.Model.VoiceSelectionParams{
                   languageCode: "en",
                   name: "en-US-Wavenet-C",
                   ssmlGender: "female"
                 }
               }
    end

    test "build_synthesize_speech_request defaults to german/female, when no language is set" do
      text = "a"
      language = nil
      voice = "female"

      {result, log} =
        with_log(fn ->
          GoogleApiServiceImpl.build_synthesize_speech_request(text, language, voice)
        end)

      assert result ==
               %GoogleApi.TextToSpeech.V1.Model.SynthesizeSpeechRequest{
                 audioConfig: %GoogleApi.TextToSpeech.V1.Model.AudioConfig{
                   audioEncoding: "MP3"
                 },
                 input: %GoogleApi.TextToSpeech.V1.Model.SynthesisInput{
                   text: text
                 },
                 voice: %GoogleApi.TextToSpeech.V1.Model.VoiceSelectionParams{
                   languageCode: "de",
                   name: "de-DE-Wavenet-A",
                   ssmlGender: "female"
                 }
               }

      assert log =~ "Language / Gender combination not found!"
    end

    test "build_synthesize_speech_request defaults to language/female, when no voice is set" do
      text = "a"
      language = :en
      voice = nil

      assert GoogleApiServiceImpl.build_synthesize_speech_request(text, language, voice) ==
               %GoogleApi.TextToSpeech.V1.Model.SynthesizeSpeechRequest{
                 audioConfig: %GoogleApi.TextToSpeech.V1.Model.AudioConfig{
                   audioEncoding: "MP3"
                 },
                 input: %GoogleApi.TextToSpeech.V1.Model.SynthesisInput{
                   text: text
                 },
                 voice: %GoogleApi.TextToSpeech.V1.Model.VoiceSelectionParams{
                   languageCode: "en",
                   name: "en-US-Wavenet-C",
                   ssmlGender: "female"
                 }
               }
    end
  end
end
