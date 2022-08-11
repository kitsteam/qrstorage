defmodule Qrstorage.Services.Gcp.GoogleApiServiceImplTest do
  use ExUnit.Case, async: true

  alias Qrstorage.Services.Gcp.GoogleApiServiceImpl

  describe "build_synthesize_speech_request/3" do
    test "build_synthesize_speech_request contains text, language and voice" do
      text = "a"
      language = "en"
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
                   languageCode: language,
                   ssmlGender: voice
                 }
               }
    end

    test "build_synthesize_speech_request defaults to german, when no language is set" do
      text = "a"
      language = nil
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
                   languageCode: "de",
                   ssmlGender: voice
                 }
               }
    end

    test "build_synthesize_speech_request defaults to female, when no voice is set" do
      text = "a"
      language = "en"
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
                   languageCode: language,
                   ssmlGender: "female"
                 }
               }
    end
  end
end
