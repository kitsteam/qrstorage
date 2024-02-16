defmodule QrstorageWeb.QrCodeController do
  use QrstorageWeb, :controller

  alias Qrstorage.QrCodes
  alias Qrstorage.QrCodes.QrCode
  alias Qrstorage.Repo

  require Logger

  def audio_file(conn, %{"id" => id}) do
    qr_code = Repo.get!(QrCode, id)

    # ::TODO::    audio_file_type = if qr_code.audio_file_type, do: qr_code.audio_file_type, else: "audio/mp3"

    Logger.info("file type:")
    Logger.info(qr_code.audio_file_type)

    conn
    |> put_resp_content_type(qr_code.audio_file_type, "utf-8")
    |> send_resp(200, qr_code.audio_file)
  end

  def new(conn, _params) do
    changeset = QrCodes.change_qr_code(%QrCode{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"qr_code" => qr_code_params}) do
    case Qrstorage.Services.QrCodeService.create_qr_code(qr_code_params) do
      {:ok, qr_code} ->
        conn =
          if QrCode.stored_indefinitely?(qr_code),
            do: put_flash(conn, :admin_url_id, qr_code.admin_url_id),
            else: conn

        conn
        |> redirect(to: Routes.qr_code_path(conn, :download, qr_code))

      {:error, %Ecto.Changeset{} = changeset, error_message} ->
        conn = put_flash(conn, :error, error_message)
        render(conn, "new.html", changeset: changeset)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    qr_code = QrCodes.get_qr_code!(id)

    if qr_code.content_type == :link do
      # we don't want to redirect to external links:
      redirect(conn, to: "/")
    else
      render(conn, "show.html", qr_code: qr_code)
    end
  end

  def preview(conn, %{"id" => id}) do
    qr_code = QrCodes.get_qr_code!(id)

    if qr_code.content_type == :link do
      # we don't want to redirect to links:
      redirect(conn, to: "/")
    else
      render(conn, "preview.html", qr_code: qr_code)
    end
  end

  def download(conn, %{"id" => id}) do
    qr_code = QrCodes.get_qr_code!(id)
    render(conn, "download.html", qr_code: qr_code)
  end

  def admin(conn, %{"admin_url_id" => admin_url_id}) do
    qr_code = QrCodes.get_qr_code_by_admin_url_id!(admin_url_id)
    render(conn, "admin.html", qr_code: qr_code)
  end

  def delete(conn, %{"admin_url_id" => admin_url_id}) do
    QrCodes.get_qr_code_by_admin_url_id!(admin_url_id)
    |> QrCodes.delete_qr_code()

    conn
    |> put_flash(:info, gettext("Successfully deleted QR code."))
    |> redirect(to: "/")
  end
end
