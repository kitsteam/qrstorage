defmodule QrstorageTextScrubberTest do
  use ExUnit.Case, async: true

  alias FastSanitize.Sanitizer
  alias Qrstorage.Scrubber.TextScrubber

  defp sanitize(text) do
    Sanitizer.scrub(text, TextScrubber)
  end

  test "allows complex links" do
    text =
      ~S(<a href="https://www.example.com" class="ql-color-#e60000 ql-bg-#ffff00" rel="noopener noreferrer" target="_blank">Link</a>)

    assert sanitize(text) == {:ok, text}
  end

  test "allows classes on p to allow for colored text and backgrounds" do
    text = ~S(<p class="ql-color-#e60000 ql-bg-#ffff00">p</p>)

    assert sanitize(text) == {:ok, text}
  end

  test "allows classes on strong to allow for colored text and backgrounds" do
    text = ~S(<strong class="ql-color-#e60000 ql-bg-#ffff00">strong</strong>)

    assert sanitize(text) == {:ok, text}
  end

  test "allows classes on em to allow for colored text and backgrounds" do
    text = ~S(<em class="ql-color-#e60000 ql-bg-#ffff00">em</em>)

    assert sanitize(text) == {:ok, text}
  end

  test "allows classes on u to allow for colored text and backgrounds" do
    text = ~S(<u class="ql-color-#e60000 ql-bg-#ffff00">u</u>)

    assert sanitize(text) == {:ok, text}
  end

  test "allows classes on s to allow for colored text and backgrounds" do
    text = ~S(<s class="ql-color-#e60000 ql-bg-#ffff00">s</s>)

    assert sanitize(text) == {:ok, text}
  end

  test "allows classes on span to allow for colored text and backgrounds" do
    text = ~S(<span class="ql-color-#e60000 ql-bg-#ffff00">span</span>)

    assert sanitize(text) == {:ok, text}
  end

  test "allow right align on paragraphs" do
    text = ~S(<p class="ql-align-right">Right</p>)
    assert sanitize(text) == {:ok, text}
  end

  test "allow center align on paragraphs" do
    text = ~S(<p class="ql-align-center">Right</p>)
    assert sanitize(text) == {:ok, text}
  end

  test "leave allowed tags included" do
    text = ~S(<p><strong><em><u>Text</u></em></strong></p>)
    assert sanitize(text) == {:ok, text}
  end

  test "filters script tags" do
    text = "<script>filtered</script>"
    filtered = "filtered"
    assert sanitize(text) == {:ok, filtered}
  end

  test "filters javascript handler" do
    text = ~S(<a href="javascript:;">link</a>)
    filtered = "<a>link</a>"
    assert sanitize(text) == {:ok, filtered}
  end

  test "filters non http/https protocols" do
    text = ~S(<a href="foo://example.com">link</a>)
    filtered = "<a>link</a>"
    assert sanitize(text) == {:ok, filtered}
  end

  test "disallows valid styles usually used by quill, such as color" do
    text = ~s"""
    <span style="color: rgb(230, 0, 0);">invalid</span>
    <span style="background-color: rgb(230, 0, 0);">invalid</span>
    """

    filtered_text = ~s"""
    <span>invalid</span>
    <span>invalid</span>
    """

    assert sanitize(text) == {:ok, filtered_text}
  end

  test "filters invalid styles" do
    text = ~s"""
    <span style="invalid: rgb(230, 0, 0);">invalid</span>
    <span style="wrong: true;">invalid</span>
    """

    filtered_text = ~s"""
    <span>invalid</span>
    <span>invalid</span>
    """

    assert sanitize(text) == {:ok, filtered_text}
  end

  test "allow images with src data" do
    text = ~s"""
    <img src="data:image/jpeg;base64,abc"/>
    """

    assert sanitize(text) == {:ok, text}
  end
end
