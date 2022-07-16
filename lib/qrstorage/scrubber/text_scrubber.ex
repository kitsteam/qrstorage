defmodule Qrstorage.Scrubber.TextScrubber do
  require FastSanitize.Sanitizer.Meta
  alias FastSanitize.Sanitizer.Meta

  # Meta.remove_cdata_sections_before_scrub()
  Meta.strip_comments()

  # These are the quill theme colors:
  @colors [
    "#000000",
    "#e60000",
    "#ff9900",
    "#ffff00",
    "#008a00",
    "#0066cc",
    "#9933ff",
    "#ffffff",
    "#facccc",
    "#ffebcc",
    "#ffffcc",
    "#cce8cc",
    "#cce0f5",
    "#ebd6ff",
    "#bbbbbb",
    "#f06666",
    "#ffc266",
    "#ffff66",
    "#66b966",
    "#66a3e0",
    "#c285ff",
    "#888888",
    "#a10000",
    "#b26b00",
    "#b2b200",
    "#006100",
    "#0047b2",
    "#6b24b2",
    "#444444",
    "#5c0000",
    "#663d00",
    "#666600",
    "#003700",
    "#002966",
    "#3d1466"
  ]

  # map colors to css class names:
  @allowed_font_colors Enum.map(@colors, fn color -> "ql-color-" <> color end)
  @allowed_background_colors Enum.map(@colors, fn color -> "ql-bg-" <> color end)

  @allowed_alignments ["ql-align-right", "ql-align-center"]

  @allowed_classes @allowed_alignments ++ @allowed_background_colors ++ @allowed_font_colors

  def is_tag_with_class(tag) do
    Enum.member?([:p, :strong, :em, :u, :s, :span, :a, :li], tag)
  end

  def scrub_attribute(tag, {"class", classes}) do
    valid_classes =
      case is_tag_with_class(tag) do
        true ->
          # only allow classes from @allowed_classes:
          String.split(classes, " ")
          |> Enum.filter(fn x -> Enum.member?(@allowed_classes, x) end)
          |> Enum.join(" ")

        false ->
          ""
      end

    {"class", valid_classes}
  end

  # allow tags:
  Meta.allow_tags_and_scrub_their_attributes([
    :p,
    :strong,
    :em,
    :u,
    :s,
    :span,
    :a,
    :ol,
    :ul,
    :li,
    :br,
    :img
  ])

  # allow data for img:
  Meta.allow_tag_with_uri_attributes(:img, ["src"], ["data"])

  # allow href, target and rel for links:
  Meta.allow_tag_with_uri_attributes(:a, ["href"], ["https", "http"])
  Meta.allow_tag_with_this_attribute_values(:a, "target", ["_blank"])

  Meta.allow_tag_with_this_attribute_values(:a, "rel", [
    "noopener",
    "noreferrer",
    "noopener noreferrer"
  ])

  Meta.strip_everything_not_covered()
end
