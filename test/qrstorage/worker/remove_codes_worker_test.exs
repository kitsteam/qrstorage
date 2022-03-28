defmodule QrstorageRemoveCodesWorkerTest do
  use ExUnit.Case, async: true
  use Oban.Testing, repo: Qrstorage.Repo

  alias Qrstorage.QrCodes.QrCode
  alias Qrstorage.QrCodes
  alias Qrstorage.Repo

  describe "perform" do
    @valid_attrs %{
      delete_after: ~D[2010-04-17],
      text: "some text",
      hide_text: false,
      content_type: "text",
      language: nil,
      deltas: %{"id" => "test"}
    }

    def qr_code_fixture(attrs \\ %{}) do
      {:ok, qr_code} =
        attrs
        |> Enum.into(@valid_attrs)
        |> QrCodes.create_qr_code()

      qr_code
    end

    def infinity_qr_code() do
      attrs = %{@valid_attrs | delete_after: Timex.end_of_year(QrCode.max_delete_after_year())}
      qr_code_fixture(attrs)
    end

    def overdue_qr_code() do
      attrs = %{@valid_attrs | delete_after: Timex.shift(Timex.now(), months: -5)}
      qr_code_fixture(attrs)
    end

    def active_qr_code() do
      attrs = %{@valid_attrs | delete_after: Timex.shift(Timex.now(), months: 5)}
      qr_code_fixture(attrs)
    end

    test "perform/1 deletes qr codes with a delete_after date older than now" do
      infinity_qr_code = infinity_qr_code()
      overdue_qr_code = overdue_qr_code()
      active_qr_code = active_qr_code()

      assert :ok = perform_job(Qrstorage.Worker.RemoveCodesWorker, %{})

      # only the overdue qr code is deleted:
      assert Repo.get(QrCode, infinity_qr_code.id) != nil
      assert Repo.get(QrCode, overdue_qr_code.id) == nil
      assert Repo.get(QrCode, active_qr_code.id) != nil
    end
  end
end
