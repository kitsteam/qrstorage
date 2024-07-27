defmodule Qrstorage.Services.Tts.TextToSpeechApiService do
  @callback text_to_audio(String.t(), atom(), String.t()) :: {:ok, binary()} | {:error}

  # See https://hexdocs.pm/elixir_mock/getting_started.html for why we are doing it this way:
  def text_to_audio(text, language, voice), do: impl().text_to_audio(text, language, voice)

  defp impl,
    do:
      Application.get_env(
        :qrstorage,
        :text_to_speech_service,
        Qrstorage.Services.Tts.TextToSpeechApiServiceImpl
      )
end
