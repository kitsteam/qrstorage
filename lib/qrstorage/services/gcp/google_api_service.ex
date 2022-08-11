defmodule Qrstorage.Services.Gcp.GoogleApiService do
  @callback text_to_audio(String.t(), String.t(), String.t()) :: {:ok, binary()} | {:error}

  # See https://hexdocs.pm/elixir_mock/getting_started.html for why we are doing it this way:
  def text_to_audio(text, language, voice), do: impl().text_to_audio(text, language, voice)

  defp impl,
    do:
      Application.get_env(
        :qrstorage,
        :google_api_service,
        Qrstorage.Services.Gcp.GoogleApiServiceImpl
      )
end
