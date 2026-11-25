defmodule Qrstorage.Services.ObjectStorage.ObjectStorageServiceImplTest do
  # Runs the real ExAws request/parse path (incl. sweet_xml) against a stubbed HTTP client.
  # Not async: swaps the global :ex_aws http client.
  use ExUnit.Case, async: false

  alias Qrstorage.Services.ObjectStorage.ObjectStorageServiceImpl

  defmodule HttpClientStub do
    @behaviour ExAws.Request.HttpClient

    @impl true
    def request(_method, url, _body, _headers, _http_opts) do
      # the stream runs in the calling process, so we can use its process dictionary:
      responses = Process.get(:http_stub_responses)
      send(Process.get(:http_stub_test_pid), {:request, url})

      case Map.fetch(responses, query_token(url)) do
        {:ok, body} -> {:ok, %{status_code: 200, headers: [], body: body}}
        :error -> {:ok, %{status_code: 403, headers: [], body: "forbidden"}}
      end
    end

    defp query_token(url) do
      url |> URI.parse() |> Map.get(:query, "") |> URI.decode_query() |> Map.get("continuation-token")
    end
  end

  setup do
    previous = Application.get_env(:ex_aws, :http_client)
    Application.put_env(:ex_aws, :http_client, HttpClientStub)

    on_exit(fn ->
      if previous,
        do: Application.put_env(:ex_aws, :http_client, previous),
        else: Application.delete_env(:ex_aws, :http_client)
    end)

    Process.put(:http_stub_test_pid, self())
    :ok
  end

  defp listing_xml(keys, next_token) do
    contents =
      Enum.map_join(
        keys,
        &"<Contents><Key>#{&1}</Key><LastModified>2026-11-20T10:00:00.000Z</LastModified><Size>3</Size></Contents>"
      )

    truncated = if next_token, do: "true", else: "false"
    token = if next_token, do: "<NextContinuationToken>#{next_token}</NextContinuationToken>", else: ""

    """
    <?xml version="1.0" encoding="UTF-8"?>
    <ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
      <Name>bucket</Name><Prefix>audio/</Prefix><MaxKeys>1000</MaxKeys>
      <IsTruncated>#{truncated}</IsTruncated>#{token}#{contents}
    </ListBucketResult>
    """
  end

  test "list_objects/2 parses the XML response and follows pagination" do
    Process.put(:http_stub_responses, %{
      nil => listing_xml(["audio/tts/a.mp3"], "page2"),
      "page2" => listing_xml(["audio/recording/b.webm"], nil)
    })

    assert {:ok, objects} = ObjectStorageServiceImpl.list_objects("bucket", "audio/")

    assert Enum.map(objects, & &1.key) == ["audio/tts/a.mp3", "audio/recording/b.webm"]
    assert [%{last_modified: %DateTime{year: 2026, month: 11, day: 20}} | _] = objects
    assert_received {:request, _}
    assert_received {:request, _}
  end

  test "list_objects/2 returns an error when the storage fails" do
    Process.put(:http_stub_responses, %{})

    assert {:error, _} = ObjectStorageServiceImpl.list_objects("bucket", "audio/")
  end
end
