defmodule Qrstorage.Services.RateLimitingService do
  require Logger

  alias Qrstorage.QrCodes
  alias Qrstorage.QrCodes.QrCode

  def allow?(%QrCode{} = qr_code) do
    existing_character_count = audio_character_count_in_timeframe(qr_code)

    if existing_character_count <= character_limit() do
      true
    else
      Logger.warning(
        "Rate Limit reached: QR-Code Text length: #{String.length(qr_code.text)} - Created within timeframe including QR-Code-Text-Length: #{existing_character_count} - Character Limit: #{character_limit()}."
      )

      false
    end
  end

  defp audio_character_count_in_timeframe(qr_code) do
    # We start with 24 - we can make this configurable later
    hours = 24
    past_audio_character_count = QrCodes.audio_character_count_in_last_hours(hours)
    String.length(qr_code.text) + past_audio_character_count
  end

  defp character_limit() do
    # load from config:
    Application.get_env(:qrstorage, :rate_limiting_character_limit)
  end
end
