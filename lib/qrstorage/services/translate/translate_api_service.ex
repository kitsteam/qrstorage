defmodule Qrstorage.Services.Translate.TranslateApiService do
  @callback translate(String.t(), atom()) :: {:ok, String.t()} | {:error}

  # See https://hexdocs.pm/elixir_mock/getting_started.html for why we are doing it this way:
  def translate(text, target_language), do: impl().translate(text, target_language)

  defp impl,
    do:
      Application.get_env(
        :qrstorage,
        :translate_service,
        Qrstorage.Services.Translate.TranslateApiServiceImpl
      )
end
