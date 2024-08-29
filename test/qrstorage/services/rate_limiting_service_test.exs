defmodule Qrstorage.Services.RateLimitingServiceTest do
  use Qrstorage.DataCase
  use Qrstorage.StorageCase
  use Qrstorage.RateLimitingCase

  alias Qrstorage.QrCodes.QrCode
  alias Qrstorage.Services.RateLimitingService

  describe "allow?/1 without existing audio qr codes" do
    test "allow?/1 returns false when the text is longer than the limit" do
      qr_code = qr_code_with_text_length(5)

      {result, logs} = with_log_and_rate_limit_set_to(1, fn -> RateLimitingService.allow?(qr_code) end)

      assert result == false
      assert logs =~ "Rate Limit reached"
    end

    test "allow?/1 returns true when the text is shorter than the limit" do
      qr_code = qr_code_with_text_length(5)

      {result, _logs} = with_log_and_rate_limit_set_to(15, fn -> RateLimitingService.allow?(qr_code) end)

      assert result == true
    end

    test "allow?/1 returns true when the text is equal to the limit" do
      qr_code = qr_code_with_text_length(5)

      {result, _logs} = with_log_and_rate_limit_set_to(5, fn -> RateLimitingService.allow?(qr_code) end)

      assert result == true
    end
  end

  describe "allow?/1 with existing audio qr codes" do
    setup do
      audio_qr_code_fixture(%{text: "12345"})
      :ok
    end

    test "allow?/1 returns false when the text is longer than the limit and the existing character count" do
      qr_code = qr_code_with_text_length(2)

      {result, logs} = with_log_and_rate_limit_set_to(6, fn -> RateLimitingService.allow?(qr_code) end)

      assert result == false
      assert logs =~ "Rate Limit reached"
    end

    test "allow?/1 returns true when the text is shorter than the limit and the existing character count" do
      qr_code = qr_code_with_text_length(2)

      {result, _logs} = with_log_and_rate_limit_set_to(8, fn -> RateLimitingService.allow?(qr_code) end)

      assert result == true
    end

    test "allow?/1 returns true when the text is equal to the limit and the existing character count" do
      qr_code = qr_code_with_text_length(2)

      {result, _logs} = with_log_and_rate_limit_set_to(7, fn -> RateLimitingService.allow?(qr_code) end)

      assert result == true
    end
  end

  defp qr_code_with_text_length(length) do
    text = String.duplicate("a", length)
    %QrCode{text: text}
  end
end
