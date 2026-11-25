defmodule QrstorageWeb.AudioToken do
  @moduledoc """
  Short-lived signed tokens that grant access to a single QR code's audio file.
  """

  @salt "audio_file"
  @max_age 3600

  def sign(conn_or_endpoint, qr_code_id) do
    Phoenix.Token.sign(conn_or_endpoint, @salt, qr_code_id)
  end

  def verify(conn_or_endpoint, token, qr_code_id) when is_binary(token) do
    case Phoenix.Token.verify(conn_or_endpoint, @salt, token, max_age: @max_age) do
      {:ok, id} when id == qr_code_id -> :ok
      {:ok, _other} -> {:error, :wrong_id}
      {:error, reason} -> {:error, reason}
    end
  end

  def verify(_conn_or_endpoint, _token, _qr_code_id), do: {:error, :missing}
end
