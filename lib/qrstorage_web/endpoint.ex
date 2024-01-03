defmodule QrstorageWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :qrstorage

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_qrstorage_key",
    signing_salt: "w4G2Qpx/"
  ]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :qrstorage,
    gzip: false,
    only: ~w(assets css fonts images favicon.ico robots.txt site.webmanifest browserconfig.xml)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :qrstorage
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  # account for deltas and overhead for the upload length. deltas are roughly the same size as the actual input,
  # so * 2 for deltas, plus 0.2 buffer for overhead and text characters:
  upload_length_buffer = 2.2
  max_upload_length = String.to_integer(Application.compile_env(:qrstorage, :max_upload_length))

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library(),
    length: ceil(max_upload_length * upload_length_buffer)

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug QrstorageWeb.Router
end
