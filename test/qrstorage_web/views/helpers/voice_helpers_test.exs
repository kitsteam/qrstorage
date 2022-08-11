defmodule QrstorageWeb.VoiceHelpersTest do
  use ExUnit.Case, async: true

  import QrstorageWeb.VoiceHelpers

  describe "languages_with_male_voice/0" do
    test "returns all languages with male voices as json" do
      languages = "[\"de\",\"en\",\"fr\",\"es\",\"tr\",\"pl\",\"ar\",\"ru\",\"it\",\"pt\",\"nl\"]"
      assert languages_with_male_voice() == languages
    end

    test "languages_with_male_voice/0 does not contain ukrainian" do
      assert !(languages_with_male_voice() =~ "uk")
    end
  end
end
