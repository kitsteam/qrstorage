defmodule Qrstorage.Services.Tts.TextToSpeechMapping do
  require Logger

  @voices %{
    :de => %{"female" => "Klara-Premium", "male" => "Emil-premium"},
    :en => %{"female" => "Alice-premium", "male" => "Hugh-DNN"},
    :es => %{"female" => "Pilar-premium", "male" => "Manuel-DNN"},
    :fr => %{"female" => "Roxane-premium", "male" => "Benoit-premium"},
    :tr => %{"female" => "Seda-DNN", "male" => "Ozan-DNN"},
    :pl => %{"female" => "Aneta-DNN"},
    :ar => %{"female" => "Yasmin", "male" => "Amir"},
    :ru => %{"female" => "Vera", "male" => "Aleksei"},
    :it => %{"female" => "Gaia-premium", "male" => "Matteo-premium"},
    :pt => %{"female" => "Carolina", "male" => "Tiago"},
    :nl => %{"female" => "Ilse-e2e", "male" => "Sem-e2e"},
    :uk => %{"female" => "Mila"}
  }

  @language_codes %{
    :de => "de_de",
    :en => "en_uk",
    :es => "es_es",
    :fr => "fr_fr",
    :tr => "tr_tr",
    :pl => "pl_pl",
    :ar => "ar_ar",
    :ru => "ru_ru",
    :it => "it_it",
    :pt => "pt_pt",
    :nl => "nl_nl",
    :uk => "uk_ua"
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
