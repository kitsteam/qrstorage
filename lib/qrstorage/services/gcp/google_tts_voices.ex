defmodule Qrstorage.Services.Gcp.GoogleTtsVoices do
  require Logger

  # Currently, there is a bug in GCP's voice selection. It was possible to provide a language and a gender, without setting the name of the voice
  # Unfortunately, this defaults to the female voice now - so we need to specify the specific name for all possible combinations here:
  @voices %{
    :de => %{"female" => "de-DE-Wavenet-A", "male" => "de-DE-Wavenet-B"},
    :en => %{"female" => "en-US-Wavenet-C", "male" => "en-US-Wavenet-A"},
    :fr => %{"female" => "fr-FR-Wavenet-A", "male" => "fr-FR-Wavenet-B"},
    :es => %{"female" => "es-ES-Wavenet-C", "male" => "es-ES-Wavenet-B"},
    :tr => %{"female" => "tr-TR-Wavenet-A", "male" => "tr-TR-Wavenet-B"},
    :pl => %{"female" => "pl-PL-Wavenet-A", "male" => "pl-PL-Wavenet-B"},
    :ar => %{"female" => "ar-XA-Wavenet-A", "male" => "ar-XA-Wavenet-B"},
    :ru => %{"female" => "ru-RU-Wavenet-A", "male" => "ru-RU-Wavenet-B"},
    :it => %{"female" => "it-IT-Wavenet-A", "male" => "it-IT-Wavenet-C"},
    :pt => %{"female" => "pt-PT-Wavenet-A", "male" => "pt-PT-Wavenet-B"},
    :nl => %{"female" => "nl-NL-Wavenet-A", "male" => "nl-NL-Wavenet-B"},
    # both voices are female - there are no male ukrainian voices
    :uk => %{"female" => "uk-UA-Wavenet-A", "male" => "uk-UA-Wavenet-A"}
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
        Logger.warn("Language / Gender combination not found! #{language} #{gender}")
        "de-DE-Wavenet-A"
    end
  end

  def voice(language, gender) do
    Logger.warn("Language is not an atom! #{language} #{gender}")
    # default to german female:
    "de-DE-Wavenet-A"
  end
end
