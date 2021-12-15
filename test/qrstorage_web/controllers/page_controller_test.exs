defmodule QrstorageWeb.PageControllerTest do
  use QrstorageWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "QRStorage"
  end
end
