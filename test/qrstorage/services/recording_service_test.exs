defmodule Qrstorage.Services.RecordingServiceTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog

  alias Qrstorage.Services.RecordingService

  describe "extract_recording_from_params/1" do
    test "returns :erorr when no file is present in the params" do
      params = %{}
      assert :error == RecordingService.extract_recording_from_params(params)
    end

    @tag :tmp_dir
    test "returns {:ok, audio_file, audio_file_type} when file is present", %{tmp_dir: tmp_dir} do
      # create dummy file for test:
      file_path = Path.join(tmp_dir, "recording.webm")
      File.write(file_path, "binary audio content")

      params = %{
        "audio_file" => %Plug.Upload{path: file_path, content_type: "audio/webm", filename: "recording.webm"}
      }

      assert {:ok, "binary audio content", "audio/webm"} == RecordingService.extract_recording_from_params(params)
    end

    @tag :tmp_dir
    test "returns {:error, message} when file is not present", %{tmp_dir: tmp_dir} do
      # create dummy file for test:
      file_path = Path.join(tmp_dir, "not-written.webm")

      params = %{
        "audio_file" => %Plug.Upload{path: file_path, content_type: "audio/webm", filename: "not-written.webm"}
      }

      {result, _log} = with_log(fn -> RecordingService.extract_recording_from_params(params) end)
      assert {:error, "Error while extracting audio file from plug."} == result
    end

    test "returns {:error, message} when upload type is not audio/webm" do
      params = %{
        "audio_file" => %Plug.Upload{path: "not needed", content_type: "audio/mp3", filename: "not-written.mp3"}
      }

      {result, _log} = with_log(fn -> RecordingService.extract_recording_from_params(params) end)
      assert {:error, "Error while extracting audio file from plug: Invalid content type"} == result
    end

    test "returns {:error, message} when parameter is not a Plug.Upload" do
      params = %{"audio_file" => "no Plug.Upload%"}

      {result, _log} = with_log(fn -> RecordingService.extract_recording_from_params(params) end)
      assert {:error, "Error while extracting audio file from plug."} == result
    end
  end
end
