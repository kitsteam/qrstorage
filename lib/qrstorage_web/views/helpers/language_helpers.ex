defmodule QrstorageWeb.LanguageHelpers do
  alias Qrstorage.QrCodes.QrCode

  def translated_languages_for_select() do
    Enum.map(QrCode.languages(), fn value ->
      [
        key: Gettext.dgettext(QrstorageWeb.Gettext, "languages", Atom.to_string(value)),
        value: value
      ]
    end)
  end

  def translated_colors_for_select() do
    Enum.map(QrCode.colors(), fn value ->
      [key: Gettext.dgettext(QrstorageWeb.Gettext, "colors", Atom.to_string(value)), value: value]
    end)
  end

  def translated_dots_types_for_select() do
    Enum.map(QrCode.dots_types(), fn value ->
      [key: Gettext.dgettext(QrstorageWeb.Gettext, "dots_types", Atom.to_string(value)), value: value]
    end)
  end
end
