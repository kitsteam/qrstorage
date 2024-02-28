defmodule Qrstorage.Services.QrCodeService do
  alias Qrstorage.QrCodes
  alias Qrstorage.QrCodes.QrCode
  alias Qrstorage.Repo
  alias Qrstorage.Services.RecordingService
  alias Qrstorage.Services.StorageService

  import QrstorageWeb.Gettext

  require Logger

  def create_qr_code(qr_code_params) do
    qr_code_params = qr_code_params |> convert_delete_after() |> convert_deltas()

    case QrCodes.create_qr_code(qr_code_params) do
      {:ok, %QrCode{} = qr_code} ->
        case handle_audio_types(qr_code, qr_code_params) do
          {:error, error_message} ->
            # delete qr code and show error
            Logger.error("deleting qr code after creation, because the audio part could not be saved")
            Repo.delete(qr_code)
            {:error, QrCodes.change_qr_code(%QrCode{}), error_message}

          {:ok, qr_code_with_audio} ->
            {:ok, qr_code_with_audio}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  defp convert_delete_after(qr_code_params) do
    # delete links after one day. We only need them to display the qr code properly and for preview purposes.
    delete_after =
      case Map.get(qr_code_params, "content_type") do
        "link" ->
          Timex.shift(Timex.now(), hours: 1)

        "recording" ->
          Timex.shift(Timex.now(), months: 1)

        _ ->
          months = Map.get(qr_code_params, "delete_after") |> Integer.parse() |> elem(0)

          if months == 0 do
            # Unfortunately, postgrex doesnt support postgres infinity type,
            # so we have to fall back to date far away in the future:
            # https://elixirforum.com/t/support-infinity-values-for-date-type/20713/17
            Timex.end_of_year(QrCode.max_delete_after_year())
          else
            Timex.shift(Timex.now(), months: months)
          end
      end

    qr_code_params = Map.put(qr_code_params, "delete_after", delete_after)
    qr_code_params
  end

  defp convert_deltas(qr_code_params) do
    # we need to convert the deltas to json:
    deltas_json =
      case JSON.decode(Map.get(qr_code_params, "deltas", "")) do
        {:ok, deltas_json} -> deltas_json
        {:error, _} -> %{}
      end

    qr_code_params = Map.put(qr_code_params, "deltas", deltas_json)
    qr_code_params
  end

  defp handle_audio_qr_code(%QrCode{} = qr_code) do
    # always add translation and get audio:
    case add_translation(qr_code) do
      {:error, error_message} -> {:error, error_message}
      {:ok, qr_code_with_translation} -> add_audio(qr_code_with_translation)
    end
  end

  defp handle_recording_qr_code(qr_code, qr_code_params) do
    # add recording to code:
    add_recording(qr_code, qr_code_params)
  end

  defp add_translation(%QrCode{} = qr_code) do
    Qrstorage.Services.TranslationService.add_translation(qr_code)
  end

  defp add_audio(%QrCode{} = qr_code) do
    Qrstorage.Services.TtsService.text_to_audio(qr_code)
  end

  defp handle_audio_types(qr_code, qr_code_params) do
    case qr_code.content_type do
      :audio -> handle_audio_qr_code(qr_code)
      :recording -> handle_recording_qr_code(qr_code, qr_code_params)
      _ -> {:ok, qr_code}
    end
  end

  defp add_recording(qr_code, qr_code_params) do
    case RecordingService.extract_recording_from_params(qr_code_params) do
      {:ok, audio_file, audio_file_type} ->
        case StorageService.store_recording(qr_code.id, audio_file, audio_file_type) do
          {:ok} ->
            {:ok, qr_code}

          {:error, _error_message} ->
            Logger.error("Audio file not stored: #{qr_code.id}")
            {:error, gettext("Qr code recording not extracted")}
        end

      :error ->
        {:error, gettext("Qr code recording not extracted")}
    end
  end
end
