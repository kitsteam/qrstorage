defmodule QrstorageWeb.QrCodeControllerTest do
  use QrstorageWeb.ConnCase

  alias Qrstorage.QrCodes
  alias Qrstorage.QrCodes.QrCode
  alias Qrstorage.Repo

  import Mox

  @create_attrs %{
    delete_after: "10",
    text: "some text",
    deltas: "{\"ops\":[{\"insert\":\"Assad\\n\"}]}",
    language: nil,
    content_type: "text",
    dots_type: "dots",
    voice: nil
  }

  @invalid_attrs %{delete_after: "10", text: nil, language: nil, content_type: "text"}
  @fixture_attrs %{
    delete_after: ~D[2011-05-18],
    text: "some text",
    language: nil,
    content_type: "text",
    dots_type: "dots",
    voice: nil,
    translated_text: "nil"
  }

  def fixture(attrs) do
    {:ok, qr_code} = QrCodes.create_qr_code(attrs)
    qr_code
  end

  describe "new qr_code" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.qr_code_path(conn, :new))
      assert html_response(conn, 200) =~ "form action=\"/qrcodes\""
    end
  end

  describe "create qr_code" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.qr_code_path(conn, :create), qr_code: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.qr_code_path(conn, :download, id)

      conn = get(conn, Routes.qr_code_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Qr code created successfully"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.qr_code_path(conn, :create), qr_code: @invalid_attrs)
      assert html_response(conn, 200) =~ "Oops, something went wrong"
    end

    test "uses 1 hour as the delete after date for links", %{conn: conn} do
      link_attrs = %{@create_attrs | content_type: "link", text: "https://kits.blog"}

      conn = post(conn, Routes.qr_code_path(conn, :create), qr_code: link_attrs)
      assert %{id: id} = redirected_params(conn)

      qr_code = QrCode |> Repo.get!(id)
      assert qr_code.delete_after <= Timex.shift(Timex.now(), hours: 1)
    end

    test "uses QrCode max year as deletion date for infinity", %{conn: conn} do
      link_attrs = %{@create_attrs | delete_after: "0"}
      conn = post(conn, Routes.qr_code_path(conn, :create), qr_code: link_attrs)
      assert %{id: id} = redirected_params(conn)

      qr_code = QrCode |> Repo.get!(id)
      assert qr_code.delete_after.year == QrCode.max_delete_after_year()
    end

    test "adds the admin_url_id to the flash message for QR codes that are stored indefinitely",
         %{conn: conn} do
      link_attrs = %{@create_attrs | delete_after: "0"}
      conn = post(conn, Routes.qr_code_path(conn, :create), qr_code: link_attrs)
      assert get_flash(conn, :admin_url_id) != nil
    end

    test "does not add the admin_url_id to the flash message for QR codes that are not stored indefinitely",
         %{conn: conn} do
      link_attrs = %{@create_attrs | delete_after: "1"}
      conn = post(conn, Routes.qr_code_path(conn, :create), qr_code: link_attrs)
      assert get_flash(conn, :admin_url_id) == nil
    end
  end

  describe "create audio qr_code" do
    test "audio code is successfully created", %{conn: conn} do
      Qrstorage.Services.Gcp.GoogleApiServiceMock
      |> expect(:text_to_audio, fn _text, _language, _voice ->
        {:ok, "audio binary"}
      end)
      |> expect(:translate, fn _text, _language ->
        {:ok, "translated text"}
      end)

      audio_attrs = %{@create_attrs | content_type: "audio", language: "de", voice: "male"}

      conn = post(conn, Routes.qr_code_path(conn, :create), qr_code: audio_attrs)
      assert %{id: id} = redirected_params(conn)
      qr_code = QrCode |> Repo.get!(id)
      assert qr_code.audio_file == "audio binary"
    end

    test "audio qr codes are always translated to different language", %{conn: conn} do
      Qrstorage.Services.Gcp.GoogleApiServiceMock
      |> expect(:text_to_audio, fn _text, _language, _voice ->
        {:ok, "audio binary"}
      end)
      |> expect(:translate, fn _text, _language ->
        {:ok, "translated text"}
      end)

      audio_attrs = %{
        @create_attrs
        | content_type: "audio",
          language: "de",
          voice: "male"
      }

      conn = post(conn, Routes.qr_code_path(conn, :create), qr_code: audio_attrs)
      assert %{id: id} = redirected_params(conn)
      qr_code = QrCode |> Repo.get!(id)
      assert qr_code.translated_text == "translated text"
      assert qr_code.audio_file == "audio binary"
    end

    test "text qr codes are never translated to different language", %{conn: conn} do
      conn = post(conn, Routes.qr_code_path(conn, :create), qr_code: @create_attrs)
      assert %{id: id} = redirected_params(conn)
      qr_code = QrCode |> Repo.get!(id)
      assert qr_code.translated_text == nil
      assert qr_code.audio_file == nil
    end

    test "translates is able to handle text longer than 255 chars", %{conn: conn} do
      translated_text = String.duplicate("a", 260)

      Qrstorage.Services.Gcp.GoogleApiServiceMock
      |> expect(:text_to_audio, fn _text, _language, _voice ->
        {:ok, "audio binary"}
      end)
      |> expect(:translate, fn _text, _language ->
        {:ok, translated_text}
      end)

      audio_attrs = %{
        @create_attrs
        | content_type: "audio",
          language: "de",
          voice: "male"
      }

      conn = post(conn, Routes.qr_code_path(conn, :create), qr_code: audio_attrs)
      assert %{id: id} = redirected_params(conn)
      qr_code = QrCode |> Repo.get!(id)
      assert qr_code.translated_text == translated_text
      assert qr_code.audio_file == "audio binary"
    end
  end

  describe "show qr_code" do
    setup [:create_audio_qr_code, :create_link_qr_code, :create_translated_audio_qr_code]

    test "hides text for audio files by default", %{conn: conn, audio_qr_code: audio_qr_code} do
      conn = get(conn, Routes.qr_code_path(conn, :show, audio_qr_code.id))
      assert !(html_response(conn, 200) =~ audio_qr_code.text)
    end

    test "doesnt hide text for audio files with hide_text set to false", %{
      conn: conn,
      audio_qr_code: audio_qr_code
    } do
      audio_qr_code
      |> QrCode.changeset(%{hide_text: false})
      |> Repo.update!()

      conn = get(conn, Routes.qr_code_path(conn, :show, audio_qr_code.id))
      assert html_response(conn, 200) =~ audio_qr_code.text
    end

    test "that links redirect to the link", %{
      conn: conn,
      link_qr_code: link_qr_code
    } do
      conn = get(conn, Routes.qr_code_path(conn, :show, link_qr_code.id))
      assert html_response(conn, 302) =~ link_qr_code.text
    end

    test "that codes with translated text prefer the translation", %{
      conn: conn,
      translated_audio_qr_code: translated_audio_qr_code
    } do
      conn = get(conn, Routes.qr_code_path(conn, :show, translated_audio_qr_code.id))
      response = html_response(conn, 200)
      assert response =~ translated_audio_qr_code.translated_text
      assert !(response =~ translated_audio_qr_code.text)
    end

    test "shows hint that text was translated for translated codes", %{
      conn: conn,
      translated_audio_qr_code: translated_audio_qr_code
    } do
      conn = get(conn, Routes.qr_code_path(conn, :show, translated_audio_qr_code.id))
      assert html_response(conn, 200) =~ "Text was automatically translated"
    end

    test "shows no hint that text was translated for not translated codes", %{
      conn: conn,
      audio_qr_code: audio_qr_code
    } do
      conn = get(conn, Routes.qr_code_path(conn, :show, audio_qr_code.id))
      assert !(html_response(conn, 200) =~ "Text was automatically translated")
    end
  end

  describe "preview qr_code" do
    setup [
      :create_text_qr_code,
      :create_audio_qr_code,
      :create_link_qr_code,
      :create_translated_audio_qr_code
    ]

    test "that audio qr codes show a preview", %{conn: conn, audio_qr_code: audio_qr_code} do
      conn = get(conn, Routes.qr_code_path(conn, :preview, audio_qr_code.id))
      assert html_response(conn, 200) =~ "/qrcodes/download/"
    end

    test "that translated audio qr codes show a hint that they were translated", %{
      conn: conn,
      translated_audio_qr_code: translated_audio_qr_code
    } do
      conn = get(conn, Routes.qr_code_path(conn, :preview, translated_audio_qr_code.id))
      assert html_response(conn, 200) =~ "Text was automatically translated."
    end

    test "that non-translated audio qr codes do not show a hint that they were translated", %{
      conn: conn,
      audio_qr_code: audio_qr_code
    } do
      conn = get(conn, Routes.qr_code_path(conn, :preview, audio_qr_code.id))
      assert !(html_response(conn, 200) =~ "Text was automatically translated.")
    end

    test "that text qr codes show a preview", %{conn: conn, text_qr_code: text_qr_code} do
      conn = get(conn, Routes.qr_code_path(conn, :preview, text_qr_code.id))
      assert html_response(conn, 200) =~ text_qr_code.text
    end

    test "that links redirect to the link", %{
      conn: conn,
      link_qr_code: link_qr_code
    } do
      conn = get(conn, Routes.qr_code_path(conn, :preview, link_qr_code.id))
      assert html_response(conn, 302) =~ link_qr_code.text
    end
  end

  describe "download qr_code" do
    setup [:create_audio_qr_code, :create_link_qr_code, :create_text_qr_code]

    test "that qr codes with type link contain the url directly", %{
      conn: conn,
      link_qr_code: link_qr_code
    } do
      conn = get(conn, Routes.qr_code_path(conn, :download, link_qr_code.id))
      assert html_response(conn, 200) =~ "data-url=\"" <> link_qr_code.text
    end

    test "that qr codes with type audio contain the url to qrstorage", %{
      conn: conn,
      audio_qr_code: audio_qr_code
    } do
      conn = get(conn, Routes.qr_code_path(conn, :download, audio_qr_code.id))

      assert html_response(conn, 200) =~
               "data-url=\"" <> Routes.qr_code_url(conn, :show, audio_qr_code.id)
    end

    test "that qr codes with type text contain the url to qrstorage", %{
      conn: conn,
      text_qr_code: text_qr_code
    } do
      conn = get(conn, Routes.qr_code_path(conn, :download, text_qr_code.id))

      assert html_response(conn, 200) =~
               "data-url=\"" <> Routes.qr_code_url(conn, :show, text_qr_code.id)
    end
  end

  describe "delete qr_code" do
    setup [:create_text_qr_code]

    test "that delete qr_code deletes a qr_code by admin_url_id", %{
      conn: conn,
      text_qr_code: text_qr_code
    } do
      assert Repo.get(QrCode, text_qr_code.id) != nil

      delete(conn, Routes.qr_code_path(conn, :delete, text_qr_code.admin_url_id))

      assert Repo.get(QrCode, text_qr_code.id) == nil
    end

    test "that delete qr_code does not deletes a qr_code by its id", %{
      conn: conn,
      text_qr_code: text_qr_code
    } do
      assert Repo.get(QrCode, text_qr_code.id) != nil

      assert_raise Ecto.NoResultsError, fn ->
        delete(conn, Routes.qr_code_path(conn, :delete, text_qr_code.id))
      end

      assert Repo.get(QrCode, text_qr_code.id) != nil
    end
  end

  describe "admin" do
    setup [:create_text_qr_code]

    test "that the admin page contains a delete button", %{conn: conn, text_qr_code: text_qr_code} do
      conn = get(conn, Routes.qr_code_path(conn, :admin, text_qr_code.admin_url_id))

      assert html_response(conn, 200) =~
               "data-method=\"delete\" data-to=\"/qrcodes/delete/#{text_qr_code.admin_url_id}"
    end
  end

  defp create_audio_qr_code(_) do
    attrs = %{@fixture_attrs | content_type: "audio", language: "de", voice: "female"}
    audio_qr_code = fixture(attrs)

    # we set translated_text to text, since this is what happens when google detects no difference between source and target language
    # we also add a fake audio file
    audio_qr_code =
      audio_qr_code
      |> QrCode.changeset(%{hide_text: audio_qr_code.hide_text})
      |> QrCode.changeset_with_translated_text(%{translated_text: audio_qr_code.text})
      |> QrCode.store_audio_file(%{
        "audio_file" => "some binary text",
        "audio_file_type" => "audio/mp3"
      })
      |> Repo.update!()

    %{audio_qr_code: audio_qr_code}
  end

  defp create_translated_audio_qr_code(context) do
    audio_qr_code = create_audio_qr_code(context)[:audio_qr_code]

    # set translation and make text visible:
    translated_audio_qr_code =
      audio_qr_code
      |> QrCode.changeset(%{hide_text: false})
      |> QrCode.changeset_with_translated_text(%{translated_text: "translated text"})
      |> Repo.update!()

    %{translated_audio_qr_code: translated_audio_qr_code}
  end

  defp create_link_qr_code(_) do
    attrs = %{@fixture_attrs | content_type: "link", text: "https://kits.blog"}
    qr_code = fixture(attrs)

    %{link_qr_code: qr_code}
  end

  defp create_text_qr_code(_) do
    attrs = %{@fixture_attrs | content_type: "text", text: "some text"}
    qr_code = fixture(attrs)

    %{text_qr_code: qr_code}
  end
end
