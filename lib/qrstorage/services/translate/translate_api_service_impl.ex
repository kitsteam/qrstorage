defmodule Qrstorage.Services.Translate.TranslateApiServiceImpl do
  alias Qrstorage.Services.Translate.TranslateApiService
  require Logger

  @behaviour TranslateApiService

  @deepl_language_atoms %{
    :de => :DE,
    :en => :EN,
    :fr => :FR,
    :es => :ES,
    :tr => :TR,
    :pl => :PL,
    :ar => :AR,
    :ru => :RU,
    :it => :IT,
    :pt => :PT,
    :nl => :NL,
    :uk => :UK,
    :cs => :CS,
    :el => :EL,
    :fi => :FI,
    :hu => :HU,
    :sk => :SK,
    :ro => :RO
  }

  @impl TranslateApiService
  def translate(text, target_language) do
    case DeeplEx.translate(text, :DETECT, map_target_language(target_language)) do
      {:ok, %Tesla.Env{status: status, body: response_body}} ->
        Logger.error("Error while translating text: status: #{status} message: #{response_body}")
        {:error}

      {:ok, translation} when is_bitstring(translation) ->
        {:ok, translation}

      _ ->
        Logger.error("Error while translating text: #{target_language}")
        {:error}
    end
  end

  @spec map_target_language(atom()) :: atom()
  def map_target_language(target_language) do
    case @deepl_language_atoms[target_language] do
      nil ->
        Logger.warning("Language code not found for language: #{target_language}")
        "de_de"

      language ->
        language
    end
  end
end
