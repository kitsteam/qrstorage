defmodule QrstorageWeb.QrCodeController do
  use QrstorageWeb, :controller

  alias Qrstorage.QrCodes
  alias Qrstorage.QrCodes.QrCode
  alias Qrstorage.Repo

  def audio_file(conn, %{"id" => id}) do
      qr_code = Repo.get!(QrCode, id)
      conn
      |> put_resp_content_type(qr_code.audio_file_type, "utf-8")
      |> send_resp(200, qr_code.audio_file)
  end


  def new(conn, _params) do
    changeset = QrCodes.change_qr_code(%QrCode{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"qr_code" => qr_code_params}) do
    months = Map.get(qr_code_params, "delete_after") |> Integer.parse |> elem(0)
    new_params = Map.put(qr_code_params, "delete_after", Timex.shift(Timex.now(), months: months))

    case QrCodes.create_qr_code(new_params) do
      {:ok, qr_code} ->
        if qr_code.language != :none do
          Qrstorage.TtsService.text_to_audio(qr_code)
        end

        conn
        |> put_flash(:info, gettext("Qr code created successfully."))
        |> redirect(to: Routes.qr_code_path(conn, :show, qr_code))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    qr_code = QrCodes.get_qr_code!(id)
    render(conn, "show.html", qr_code: qr_code)
  end
end
