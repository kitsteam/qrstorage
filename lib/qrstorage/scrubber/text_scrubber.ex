defmodule Qrstorage.Scrubber.TextScrubber do
  require FastSanitize.Sanitizer.Meta
  alias FastSanitize.Sanitizer.Meta

  # Meta.remove_cdata_sections_before_scrub()
  Meta.strip_comments()

  @allowed_alignments ["ql-align-right", "ql-align-center"]

  # tags:
  Meta.allow_tag_with_these_attributes(:img, [""])
  Meta.allow_tag_with_uri_attributes(:img, ["src"], ["data"])

  # allow class for background and font color classes:
  Meta.allow_tag_with_these_attributes(:p, ["class"])
  Meta.allow_tag_with_these_attributes(:strong, ["class"])
  Meta.allow_tag_with_these_attributes(:em, ["class"])
  Meta.allow_tag_with_these_attributes(:u, ["class"])
  Meta.allow_tag_with_these_attributes(:s, ["class"])
  Meta.allow_tag_with_these_attributes(:span, ["class"])

  Meta.allow_tag_with_these_attributes(:ol, [])
  Meta.allow_tag_with_these_attributes(:ul, [])
  Meta.allow_tag_with_these_attributes(:li, [])
  Meta.allow_tag_with_this_attribute_values(:li, "class", @allowed_alignments)

  Meta.allow_tag_with_these_attributes(:br, [])

  Meta.allow_tag_with_these_attributes(:a, ["class"])
  Meta.allow_tag_with_uri_attributes(:a, ["href"], ["https", "http"])
  Meta.allow_tag_with_this_attribute_values(:a, "target", ["_blank"])

  Meta.allow_tag_with_this_attribute_values(:a, "rel", [
    "noopener",
    "noreferrer",
    "noopener noreferrer"
  ])

  Meta.strip_everything_not_covered()
end
