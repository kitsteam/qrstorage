# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :qrstorage,
  ecto_repos: [
    Qrstorage.Repo
  ],
  generators: [
    binary_id: true
  ]

# Configures the endpoint
config :qrstorage, QrstorageWeb.Endpoint,
  url: [host: "localhost"],
  live_view: [
    signing_salt: "HU38qcFR"
  ],
  pubsub_server: Qrstorage.PubSub,
  render_errors: [
    view: QrstorageWeb.ErrorView,
    accepts: ~w(html json),
    layout: false
  ]

# This is what will be used for the calculation on the client side. We add a buffer to account for deltas
# and overhead in the endpoint configuration, so the server actually allows for a bit more:
config :qrstorage, max_upload_length: System.get_env("QR_CODE_MAX_UPLOAD_LENGTH", "2666666")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [
    :request_id
  ]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.19.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2016 --external:*.webmanifest --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :dart_sass,
  version: "1.69.7",
  default: [
    args: ~w(css/app.scss ../priv/static/assets/app.css),
    cd: Path.expand("../assets", __DIR__)
  ]

# Tesla uses httpc as a default adapter. httpc does not verify TLS certificates, so we use Hackney:
config :tesla, adapter: {Tesla.Adapter.Hackney, []}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
