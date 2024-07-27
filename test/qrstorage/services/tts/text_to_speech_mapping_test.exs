defmodule Qrstorage.Services.Tts.TextToSpeechMappingTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog

  alias Qrstorage.Services.Tts.TextToSpeechMapping

  describe "voice/2" do
    test "that voice/2 returns a name with valid input" do
      assert TextToSpeechMapping.voice(:de, "male") == "Emil-premium"
    end

    test "that voice/2 returns the default german voice with non existing language" do
      {result, log} =
        with_log(fn ->
          TextToSpeechMapping.voice(:missing, "none")
        end)

      assert result == "Klara-Premium"
      assert log =~ "Language / Gender combination not found"
    end

    test "that voice/2 returns the default german voice without language" do
      {result, log} =
        with_log(fn ->
          TextToSpeechMapping.voice(nil, "none")
        end)

      assert result == "Klara-Premium"
      assert log =~ " Language / Gender combination not found!"
    end

    test "that voice/2 returns the female language voice without gender" do
      assert TextToSpeechMapping.voice(:en, "none") == "Alice-premium"
    end
  end
end
