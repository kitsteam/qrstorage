defmodule QrstorageWeb.QrCodeController do
  use QrstorageWeb, :controller

  alias Qrstorage.QrCodes
  alias Qrstorage.QrCodes.QrCode
  alias Qrstorage.Repo
  alias Qrstorage.Services.StorageService

  require Logger

  def audio_file(conn, %{"id" => id}) do
    qr_code = Repo.get!(QrCode, id)

    case qr_code.content_type do
      :recording ->
        send_file(conn, qr_code)

      :audio ->
        if qr_code.audio_file != nil do
          # old qr_codes will have the file stored in the database, so the field is populated. newer codes will need to access the object storage:
          conn
          |> put_resp_content_type(qr_code.audio_file_type, nil)
          |> send_resp(200, qr_code.audio_file)
        else
          send_file(conn, qr_code)
        end

      _ ->
        conn
        |> send_resp(404, "qr code type does not have a audio file")
    end
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

  defp send_file(conn, qr_code) do
    case StorageService.get_file_by_type(qr_code.id, qr_code.content_type) do
      {:ok, audio_file} ->
        # For now, this is always audio/mp3. If we decide to add more file formats for recordings, we can change this in the future.
        # However, we don't want this to be user configurable at the moment:
        conn
        |> put_resp_content_type("audio/mp3", nil)
        |> send_resp(200, audio_file)

      {:error, error_message} ->
        conn
        |> send_resp(404, error_message)
    end
  end
end
