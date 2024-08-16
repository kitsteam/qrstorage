defmodule Qrstorage.Services.Tts.TextToSpeechApiServiceImplTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog

  alias Qrstorage.Services.Tts.TextToSpeechApiServiceImpl

  describe "text_to_audio/3" do
    test "that text_to_audio/3 returns file" do
      Tesla.Mock.mock(fn
        %{method: :post, url: "https://scapi-eu.readspeaker.com/a/speak"} ->
          %Tesla.Env{status: 200, body: "Hallo Welt"}
      end)

      assert TextToSpeechApiServiceImpl.text_to_audio("Hello World", :de, "female") == {:ok, "Hallo Welt"}
    end

    test "that text_to_audio/3 logs error" do
      Tesla.Mock.mock(fn
        %{method: :post, url: "https://scapi-eu.readspeaker.com/a/speak"} ->
          %Tesla.Env{status: 500, body: "Error while processig the request"}
      end)

      {result, log} = with_log(fn -> TextToSpeechApiServiceImpl.text_to_audio("Hello World", :de, "female") end)

      assert result ==
               {:error, "Error while creating text to speech transformation"}

      assert log =~ "[error]"
    end
  end
end
