defmodule QrstorageWeb.VoiceHelpers do
  def languages_with_male_voice() do
    Qrstorage.Services.Tts.TextToSpeechMapping.voices()
    |> Enum.reject(fn {_, value} -> value["male"] == nil end)
    |> Enum.map(fn {language, _} -> Atom.to_string(language) end)
    |> Jason.encode!()
  end
end
