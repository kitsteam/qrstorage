defmodule QrstorageWeb.VoiceHelpersTest do
  use ExUnit.Case, async: true

  import QrstorageWeb.VoiceHelpers

  describe "languages_with_male_voice/0" do
    test "returns all languages with male voices as json" do
      languages = ["es", "nl", "fr", "tr", "de", "en", "ar", "ru", "it", "pt", "fi", "hu", "sk"]
      assert Enum.sort(Jason.decode!(languages_with_male_voice())) == Enum.sort(languages)
    end

    test "languages_with_male_voice/0 does not contain ukrainian" do
      assert !(languages_with_male_voice() =~ "uk")
    end
  end
end
