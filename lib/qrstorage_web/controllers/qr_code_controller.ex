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
    qr_code_params = qr_code_params |> convert_delete_after() |> convert_deltas()

    case QrCodes.create_qr_code(qr_code_params) do
      {:ok, qr_code} ->
        if qr_code.content_type == :audio do
          Qrstorage.Services.TtsService.text_to_audio(qr_code)
        end

        conn =
          if QrCode.stored_indefinitely?(qr_code),
            do: conn |> put_flash(:admin_url_id, qr_code.admin_url_id),
            else: conn

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

  defp convert_delete_after(qr_code_params) do
    # delete links after one day. We only need them to display the qr code properly and for preview purposes.
    delete_after =
      if Map.get(qr_code_params, "content_type") == "link" do
        Timex.shift(Timex.now(), hours: 1)
      else
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
end
