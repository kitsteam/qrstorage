defmodule QrstorageWeb.ErrorViewTest do
  use QrstorageWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.html" do
    assert render_to_string(QrstorageWeb.ErrorView, "404.html", []) =~ "Not found"
  end

  test "renders 500.html" do
    assert render_to_string(QrstorageWeb.ErrorView, "500.html", []) =~ "Internal server error"
  end
end
