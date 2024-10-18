defmodule Qrstorage.Services.Translate.TranslateApiServiceImplTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog

  alias Qrstorage.Services.Translate.TranslateApiServiceImpl

  describe "map_target_language/1" do
    test "that map returns an uppercase atom" do
      assert TranslateApiServiceImpl.map_target_language(:de) == :DE
    end
  end

  describe "translate/2" do
    test "that translate/2 translates text" do
      Tesla.Mock.mock(fn
        %{method: :post, url: "https://api.deepl.com/v2/translate"} ->
          %Tesla.Env{status: 200, body: %{"translations" => [%{"text" => "Hallo Welt"}]}}
      end)

      assert TranslateApiServiceImpl.translate("Hello World", :de) == {:ok, "Hallo Welt"}
    end

    test "that translate/2 logs deepl errors" do
      Tesla.Mock.mock(fn
        %{method: :post, url: "https://api.deepl.com/v2/translate"} ->
          %Tesla.Env{status: 500, headers: [{"authorization", "test"}], body: "Error while processing the request"}
      end)

      {result, log} = with_log(fn -> TranslateApiServiceImpl.translate("Hello World", :de) end)

      assert result == {:error}
      assert log =~ "[error]"
    end

    test "that translate/2 handles responses that are not strings" do
      Tesla.Mock.mock(fn
        %{method: :post, url: "https://api.deepl.com/v2/translate"} ->
          %{other: "format"}
      end)

      {result, log} = with_log(fn -> TranslateApiServiceImpl.translate("Hello World", :de) end)

      assert result == {:error}
      assert log =~ "[error]"
    end
  end
end
