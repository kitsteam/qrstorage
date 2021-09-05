defmodule QrstorageWeb.QrCodeView do
  use QrstorageWeb, :view

  def convert_links(text \\ "") do
    html_escape(text) |> safe_to_string() |> AutoLinker.link()
  end
end
