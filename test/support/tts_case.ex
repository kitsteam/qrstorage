defmodule Qrstorage.TtsCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the Google API for TTS.
  """
  import Mox

  use ExUnit.CaseTemplate

  using do
    quote do
      import Qrstorage.TtsCase
    end
  end

  def mockTtsServiceSuccess(mock_file_content \\ "mock audio file content", translated_text \\ "translated text") do
    Qrstorage.Services.Gcp.GoogleApiServiceMock
    |> expect(:text_to_audio, fn _text, _language, _voice ->
      {:ok, mock_file_content}
    end)
    |> expect(:translate, fn _text, _language ->
      {:ok, translated_text}
    end)

    mock_file_content
  end

  def mockTtsServiceError() do
    Qrstorage.Services.Gcp.GoogleApiServiceMock
    |> expect(:text_to_audio, fn _text, _language, _voice ->
      {:error, "error"}
    end)
    |> expect(:translate, fn _text, _language ->
      {:ok, "translated text"}
    end)
  end

  def mockLanguageServiceError() do
    Qrstorage.Services.Gcp.GoogleApiServiceMock
    |> expect(:translate, fn _text, _language ->
      {:error, "text not translated"}
    end)
  end
end
