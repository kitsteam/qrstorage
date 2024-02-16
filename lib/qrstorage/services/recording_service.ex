defmodule Qrstorage.Services.RecordingService do
  require Logger

  import QrstorageWeb.Gettext

  def extract_recording_from_params(params) do
    if Map.has_key?(params, "audio_file") do
      extract_recording_from_plug_upload(params["audio_file"])
    else
      :error
    end
  end

  defp extract_recording_from_plug_upload(%Plug.Upload{} = upload) do
    case File.read(upload.path) do
      {:ok, audio_file} ->
        {:ok, audio_file, upload.content_type}

      {:error, _} ->
        Logger.error("Error while extracting audio file from plug")
        {:error, gettext("Error while extracting audio file from plug.")}
    end
  end

  defp extract_recording_from_plug_upload(_) do
    Logger.error("Error while extracting audio file from plug, plug not found in params")
    {:error, gettext("Error while extracting audio file from plug.")}
  end
end
