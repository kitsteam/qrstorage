defmodule Qrstorage.Services.Translate.TranslateApiServiceImplTest do
  use ExUnit.Case, async: true

  alias Qrstorage.Services.Translate.TranslateApiServiceImpl

  describe "map_target_language/1" do
    test "that map returns an uppercase atom" do
      assert TranslateApiServiceImpl.map_target_language(:de) == :DE
    end
  end
end
