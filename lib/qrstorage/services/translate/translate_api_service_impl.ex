defmodule Qrstorage.Services.Translate.TranslateApiServiceImpl do
  alias Qrstorage.Services.Translate.TranslateApiService
  require Logger

  @behaviour TranslateApiService

  @impl TranslateApiService
  def translate(text, target_language) do
    case DeeplEx.translate(text, :DETECT, map_target_language(target_language)) do
      {:ok, translation} ->
        {:ok, translation}

      {:error, message} ->
        Logger.error("Error while translating text: #{:target_language} message: #{message}")
        {:error}
    end
  end

  @spec map_target_language(atom()) :: atom()
  def map_target_language(qr_target_language) do
    deepl_target_language = String.to_atom(String.upcase(Atom.to_string(qr_target_language)))
    deepl_target_language
  end
end
