defmodule QrstorageTextScrubberTest do
  use ExUnit.Case, async: true

  alias HtmlSanitizeEx.Scrubber
  alias Qrstorage.Scrubber.TextScrubber

  defp sanitize(text) do
    Scrubber.scrub(text, TextScrubber)
  end

  test "allows complex links" do
    text =
      ~S(<a href="https://www.example.com" class="ql-align-right" rel="noopener noreferrer" target="_blank">Link</a>)

    assert sanitize(text) == text
  end

  test "allow right align on paragraphs" do
    text = ~S(<p class="ql-align-right">Right</p>)
    assert sanitize(text) == text
  end

  test "allow center align on paragraphs" do
    text = ~S(<p class="ql-align-center">Right</p>)
    assert sanitize(text) == text
  end

  test "leave allowed tags included" do
    text = ~S(<p><strong><em><u>Text</u></em></strong></p>)
    assert sanitize(text) == text
  end

  test "filters script tags" do
    text = "<script>filtered</script>"
    filtered = "filtered"
    assert sanitize(text) == filtered
  end

  test "filters javascript handler" do
    text = ~S(<a href="javascript:;">link</a>)
    filtered = "<a>link</a>"
    assert sanitize(text) == filtered
  end

  test "filters non http/https protocols" do
    text = ~S(<a href="example.com">link</a>)
    filtered = "<a>link</a>"
    assert sanitize(text) == filtered
  end

  test "allows color and background color" do
    text = ~s"""
    <span style="color: rgb(230, 0, 0);">valid</span>
    <span style="background-color: rgb(230,0,0);">valid</span>
    """

    assert sanitize(text) == text
  end

  test "filters invalid styles" do
    text = ~s"""
    <span style="invalid: rgb(230, 0, 0);">invalid</span>
    <span style="wrong: true;">invalid</span>
    """

    filtered_text = ~s"""
    <span style=";">invalid</span>
    <span style=";">invalid</span>
    """

    assert sanitize(text) == filtered_text
  end
end
