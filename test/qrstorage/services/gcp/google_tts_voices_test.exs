defmodule Qrstorage.Services.Gcp.GoogleTtsVoicesTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog

  alias Qrstorage.Services.Gcp.GoogleTtsVoices

  describe "voice/2" do
    test "that voice/2 returns a name with valid input" do
      assert GoogleTtsVoices.voice(:de, "male") == "de-DE-Wavenet-B"
    end

    test "that voice/2 returns the default german voice with non existing language" do
      {result, log} =
        with_log(fn ->
          GoogleTtsVoices.voice(:missing, "none")
        end)

      assert result == "de-DE-Wavenet-A"
      assert log =~ "Language / Gender combination not found"
    end

    test "that voice/2 returns the default german voice without language" do
      {result, log} =
        with_log(fn ->
          GoogleTtsVoices.voice(nil, "none")
        end)

      assert result == "de-DE-Wavenet-A"
      assert log =~ " Language / Gender combination not found!"
    end

    test "that voice/2 returns the default german voice with language that is not an atom" do
      {result, log} =
        with_log(fn ->
          GoogleTtsVoices.voice("not atom", "none")
        end)

      assert result == "de-DE-Wavenet-A"
      assert log =~ "Language is not an atom!"
    end

    test "that voice/2 returns the female language voice without gender" do
      assert GoogleTtsVoices.voice(:en, "none") == "en-US-Wavenet-C"
    end
  end
end
