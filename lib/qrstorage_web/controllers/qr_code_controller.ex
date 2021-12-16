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
    # delete links after one day. We only need them to display the qr code properly and for preview purposes.
    delete_after =
      if Map.get(qr_code_params, "content_type") == "link" do
        Timex.shift(Timex.now(), hours: 1)
      else
        months = Map.get(qr_code_params, "delete_after") |> Integer.parse() |> elem(0)
        Timex.shift(Timex.now(), months: months)
      end

    new_params = Map.put(qr_code_params, "delete_after", delete_after)

    case QrCodes.create_qr_code(new_params) do
      {:ok, qr_code} ->
        if qr_code.content_type == :audio do
          Qrstorage.TtsService.text_to_audio(qr_code)
        end

        conn
        |> put_flash(:info, gettext("Qr code created successfully."))
        |> redirect(to: Routes.qr_code_path(conn, :download, qr_code))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    qr_code = QrCodes.get_qr_code!(id)

    if qr_code.content_type == :link do
      redirect(conn, external: qr_code.text)
    else
      render(conn, "show.html", qr_code: qr_code)
    end
  end

  def preview(conn, %{"id" => id}) do
    qr_code = QrCodes.get_qr_code!(id)

    if qr_code.content_type == :link do
      redirect(conn, external: qr_code.text)
    else
      render(conn, "preview.html", qr_code: qr_code)
    end
  end

  def download(conn, %{"id" => id}) do
    qr_code = QrCodes.get_qr_code!(id)
    render(conn, "download.html", qr_code: qr_code)
  end
end
