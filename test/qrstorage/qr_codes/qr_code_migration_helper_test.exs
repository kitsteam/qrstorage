defmodule Qrstorage.QrCodes.QrCodeMigrationHelperTest do
  use Qrstorage.DataCase

  alias Qrstorage.QrCodes.QrCodeMigrationHelper
  alias Qrstorage.QrCodes.QrCode

  describe "add_deleter_after_months/1" do
    test "calculates the delete after duration for qr_codes based on insert_at and delete_after date" do
      Enum.each([1, 6, 12], fn month ->
        qr_code = qr_code_fixture()

        # we need to manually tore the old delete_after date. the delete_after date can no longer be set, since we are deprecating it:application
        updateDeleteAfterDate(qr_code, Timex.shift(Timex.now(), months: month))
        QrCodeMigrationHelper.add_delete_after_months(Qrstorage.Repo)

        qr_code = QrCodes.get_qr_code!(qr_code.id)
        assert qr_code.delete_after_months == month
      end)
    end

    test "calculates the delete after duration for qr_codes based on insert_at and delete_after date for link codes" do
      qr_code = qr_code_fixture()
      updateDeleteAfterDate(qr_code, Timex.shift(Timex.now(), hours: 1))
      QrCodeMigrationHelper.add_delete_after_months(Qrstorage.Repo)

      qr_code = QrCodes.get_qr_code!(qr_code.id)
      assert qr_code.delete_after_months == 0
    end

    test "calculates the delete after duration for qr_codes based on insert_at and delete_after date for infinity codes" do
      qr_code = qr_code_fixture()
      updateDeleteAfterDate(qr_code, Timex.end_of_year(QrCode.max_delete_after_year()))
      QrCodeMigrationHelper.add_delete_after_months(Qrstorage.Repo)

      qr_code = QrCodes.get_qr_code!(qr_code.id)
      assert qr_code.delete_after_months == 36
    end
  end

  describe "add_tts_to_audio_codes/1" do
    test "sets tts to correct value for exisitng audio codes" do
      qr_code = audio_qr_code_fixture()
      QrCodeMigrationHelper.add_tts_to_existing_audio_codes(Qrstorage.Repo)
      assert QrCodes.get_qr_code!(qr_code.id).tts
    end

    test "sets tts to false for other type" do
      qr_code = qr_code_fixture()
      QrCodeMigrationHelper.add_tts_to_existing_audio_codes(Qrstorage.Repo)
      assert !QrCodes.get_qr_code!(qr_code.id).tts
    end
  end

  defp updateDeleteAfterDate(qr_code, date) do
    qr_code
    |> cast(%{delete_after: date}, [:delete_after])
    |> Repo.update!()
  end
end
