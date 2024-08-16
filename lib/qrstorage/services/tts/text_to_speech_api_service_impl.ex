defmodule Qrstorage.Services.Tts.TextToSpeechApiServiceImpl do
  alias Qrstorage.Services.Tts.TextToSpeechApiService
  alias Qrstorage.Services.Tts.TextToSpeechMapping

  @behaviour TextToSpeechApiService

  use Tesla

  require Logger

  @impl TextToSpeechApiService
  def text_to_audio(text, language, voice) do
    data = %{
      key: api_key(),
      lang: TextToSpeechMapping.language_code(language),
      voice: TextToSpeechMapping.voice(language, voice),
      text: text
    }

    post_data(data)
  end

  # build dynamic client based on runtime arguments
  def client() do
    middleware = [
      {Tesla.Middleware.BaseUrl, base_url()},
      Tesla.Middleware.FormUrlencoded,
      # we need redirects, since the read speaker api redirects to the created .mp3 file
      {Tesla.Middleware.FollowRedirects, max_redirects: 1},
      {Tesla.Middleware.Logger, debug: false}
    ]

    Tesla.client(middleware)
  end

  defp post_data(data) do
    case Tesla.post(client(), "/speak", data) do
      {:ok, %Tesla.Env{status: status, body: response_body}} when status in 200..201 ->
        {:ok, response_body}

      {:ok, %Tesla.Env{status: status}} ->
        Logger.error("http error: #{status}")
        {:error, "Error while creating text to speech transformation"}

      {:error, reason} ->
        Logger.error("request failed: #{reason}")
        {:error, "Error while creating text to speech transformation"}
    end
  end

  defp api_key() do
    {:ok, api_key} = read_api_key()
    api_key
  end

  defp read_api_key() do
    case Application.get_env(:qrstorage, :readspeaker_api_key, nil) do
      nil ->
        {:error, :readspeaker_api_key_not_set}

      api_key ->
        {:ok, api_key}
    end
  end

  def base_url() do
    "https://scapi-eu.readspeaker.com/a"
  end
end