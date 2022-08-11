defmodule QrstorageWeb.VoiceHelpers do
  # google supports the following voices for the languages:
  @voice_mapping [
    %{language: :de, voices: [:male, :female]},
    %{language: :en, voices: [:male, :female]},
    %{language: :fr, voices: [:male, :female]},
    %{language: :es, voices: [:male, :female]},
    %{language: :tr, voices: [:male, :female]},
    %{language: :pl, voices: [:male, :female]},
    %{language: :ar, voices: [:male, :female]},
    %{language: :ru, voices: [:male, :female]},
    %{language: :it, voices: [:male, :female]},
    %{language: :pt, voices: [:male, :female]},
    %{language: :nl, voices: [:male, :female]},
    %{language: :uk, voices: [:female]}
  ]

  def languages_with_male_voice() do
    @voice_mapping
    |> Enum.filter(fn x -> Enum.member?(x.voices, :male) end)
    |> Enum.map(fn x -> Atom.to_string(x.language) end)
    |> Poison.encode!()
  end
end
