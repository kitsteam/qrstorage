defmodule Qrstorage.RateLimitingCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the API for TTS.
  """
  use ExUnit.CaseTemplate
  import ExUnit.CaptureLog

  using do
    quote do
      import Qrstorage.RateLimitingCase
    end
  end

  def with_log_and_rate_limit_set_to(limit, fun) do
    with_log(fn ->
      with_rate_limit_set_to(limit, fun)
    end)
  end

  def with_rate_limit_set_to(limit, fun) do
    previous_limit = Application.get_env(:qrstorage, :rate_limiting_character_limit)
    Application.put_env(:qrstorage, :rate_limiting_character_limit, limit)

    try do
      fun.()
    after
      # set limit back:
      Application.put_env(:qrstorage, :rate_limiting_character_limit, previous_limit)
    end
  end
end
