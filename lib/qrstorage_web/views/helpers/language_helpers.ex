defmodule QrstorageWeb.LanguageHelpers do
  alias Qrstorage.QrCodes.QrCode

  def translated_languages_for_select() do
    Enum.map(QrCode.languages, fn value -> [key: Gettext.dgettext(QrstorageWeb.Gettext, "languages", Atom.to_string(value)), value: value] end)
  end
end
