defmodule Qrstorage.Services.Tts.TextToSpeechMapping do
  require Logger

  @voices %{
    :de => %{"female" => "Klara-Premium", "male" => "Emil-premium"},
    :en => %{"female" => "Alice-premium"},
    :ar => %{"male" => "Amir"}
  }

  @language_codes %{
    :de => "de_de",
    :en => "en_uk",
    :ar => "ar_ar"
  }

  def voice(language, gender) when is_atom(language) do
    case @voices do
      %{^language => %{^gender => name}} ->
        # gender and language found:
        name

      %{^language => %{"female" => name}} ->
        # this occurs when no gender is found:
        name

      _ ->
        # nothing found:
        Logger.warning("Language / Gender combination not found! #{language} #{gender}")
        "Klara-Premium"
    end
  end

  def language_code(language) when is_atom(language) do
    case @language_codes[language] do
      nil ->
        Logger.warning("Language code not found for language: #{language}")
        "de_de"

      language ->
        language
    end
  end
end
