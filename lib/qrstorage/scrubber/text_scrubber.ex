defmodule Qrstorage.Scrubber.TextScrubber do
  require HtmlSanitizeEx.Scrubber.Meta
  alias HtmlSanitizeEx.Scrubber.Meta

  Meta.remove_cdata_sections_before_scrub()
  Meta.strip_comments()

  @allowed_classes ["ql-align-right", "ql-align-center"]

  # tags:
  Meta.allow_tag_with_these_attributes("p", [])
  Meta.allow_tag_with_this_attribute_values("p", "class", @allowed_classes)

  Meta.allow_tag_with_these_attributes("strong", [])
  Meta.allow_tag_with_these_attributes("em", [])
  Meta.allow_tag_with_these_attributes("u", [])
  Meta.allow_tag_with_these_attributes("s", [])
  Meta.allow_tag_with_these_attributes("span", [])

  Meta.allow_tag_with_these_attributes("ol", [])
  Meta.allow_tag_with_these_attributes("ul", [])

  Meta.allow_tag_with_these_attributes("li", [])
  Meta.allow_tag_with_this_attribute_values("li", "class", @allowed_classes)

  Meta.allow_tag_with_these_attributes("br", [])

  # allow styles:
  Meta.allow_tags_with_style_attributes(["strong", "em", "u", "s", "span", "a"])

  # links:
  # only allows http/https
  def scrub_attribute("a", {"href", "http" <> target}) do
    {"href", "http" <> target}
  end

  def scrub_attribute("a", {"href", _}) do
    nil
  end

  Meta.allow_tag_with_these_attributes("a", [])
  Meta.allow_tag_with_this_attribute_values("a", "target", ["_blank"])

  Meta.allow_tag_with_this_attribute_values("a", "rel", [
    "noopener",
    "noreferrer",
    "noopener noreferrer"
  ])

  Meta.allow_tag_with_this_attribute_values("a", "class", @allowed_classes)

  defp scrub_css(text) do
    HtmlSanitizeEx.Scrubber.CSS.scrub(text)
  end

  Meta.strip_everything_not_covered()
end
