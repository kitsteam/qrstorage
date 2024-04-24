import Config
require Logger

if config_env() == :prod do
  # configure logging:
  config :logger_json, :backend,
    metadata: [:request_id],
    json_encoder: Jason,
    formatter: LoggerJSON.Formatters.BasicLogger

  # override Elixir's Logger with logger_json:
  config :logger, backends: [LoggerJSON]
end

config :qrstorage, QrstorageWeb.Endpoint,
  url: [
    scheme: System.get_env("URL_SCHEME", "https"),
    host: System.get_env("URL_HOST"),
    port: System.get_env("URL_PORT", "443")
  ],
  static_url: [
    host: System.get_env("URL_STATIC_HOST") || System.get_env("URL_HOST") || "localhost"
  ],
  http: [
    port:
      System.get_env("PORT") ||
        Application.get_env(:qrstorage, QrstorageWeb.Endpoint)[:http][:port]
  ],
  secret_key_base: System.get_env("SECRET_KEY_BASE")

# from mix phx.gen.release
maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []

# disable on prod, because logger_json will take care of this. set to :debug for test and dev
ecto_log_level = if config_env() == :prod, do: false, else: :debug

config :qrstorage, Qrstorage.Repo,
  url: System.get_env("DATABASE_URL"),
  username: System.get_env("DATABASE_USER"),
  password: System.get_env("DATABASE_USER_PASSWORD"),
  database: System.get_env("DATABASE_NAME"),
  hostname: System.get_env("DATABASE_HOST"),
  port: String.to_integer(System.get_env("DATABASE_PORT", "5432")),
  pool_size: String.to_integer(System.get_env("POOL_SIZE", "15")),
  socket_options: maybe_ipv6,
  log: ecto_log_level,
  ssl: System.get_env("DATABASE_SSL", "true") == "true",
  ssl_opts: [
    verify: :verify_peer,
    cacerts: :public_key.cacerts_get(),
    server_name_indication: String.to_charlist(System.get_env("DATABASE_HOST")),
    customize_hostname_check: [
      match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
    ]
  ]

# This is what will be used for the calculation on the client side. We add a buffer to account for deltas
# and overhead in the endpoint configuration, so the server actually allows for a bit more:
config :qrstorage, max_upload_length: System.get_env("QR_CODE_MAX_UPLOAD_LENGTH", "2666666")

# Set possible translations
default_locale =
  case config_env() do
    :test -> "en"
    _ -> String.trim(System.get_env("QR_CODE_DEFAULT_LOCALE") || "de")
  end

config :gettext, :default_locale, default_locale
config :timex, :default_locale, default_locale

cond do
  gcp_config = System.get_env("GCP_CONFIG_PATH") ->
    Logger.info("Loading GCP Config file: #{gcp_config}")
    config :qrstorage, gcp_credentials: gcp_config |> File.read!() |> Jason.decode!()

  gcp_config = System.get_env("GCP_CONFIG_BASE64") ->
    Logger.info("Loading GCP Config from Base64.")
    config :qrstorage, gcp_credentials: gcp_config |> Base.decode64!() |> Jason.decode!()

  true ->
    config :goth, disabled: true

    Logger.warning("""
    Environment variables GCP_CONFIG_PATH or GCP_CONFIG_BASE64 are missing or empty.
    Either set a path to a GCP Config file with GCP_CONFIG_PATH or base64 encode the credentials and put them in GCP_CONFIG_BASE64
    """)
end

# Here some environment specific configurations
if config_env() == :test do
  config :qrstorage, Qrstorage.Repo,
    database: "#{System.get_env("DATABASE_NAME")}_test#{System.get_env("MIX_TEST_PARTITION")}"
end

if config_env() == :prod || config_env() == :dev do
  schedule = if config_env() == :prod, do: "@midnight", else: "* * * * *"

  config :qrstorage, Oban,
    repo: Qrstorage.Repo,
    plugins: [
      {Oban.Plugins.Cron,
       crontab: [
         {schedule, Qrstorage.Worker.RemoveCodesWorker}
       ]}
    ],
    queues: [default: 1]
end

# check all object storage system envs at once:
if config_env() == :prod || config_env() == :dev do
  config(:ex_aws, :s3,
    scheme: System.fetch_env!("OBJECT_STORAGE_SCHEME"),
    host: System.fetch_env!("OBJECT_STORAGE_HOST"),
    port: System.fetch_env!("OBJECT_STORAGE_PORT"),
    region: System.fetch_env!("OBJECT_STORAGE_REGION"),
    access_key_id: System.fetch_env!("OBJECT_STORAGE_USER"),
    secret_access_key: System.fetch_env!("OBJECT_STORAGE_PASSWORD")
  )
end

# configure cloak:
config :qrstorage, Qrstorage.Services.Vault,
  ciphers: [
    default:
      {Cloak.Ciphers.AES.GCM,
       tag: "AES.GCM.V1", key: Base.decode64!(System.fetch_env!("VAULT_ENCRYPTION_KEY_BASE64")), iv_length: 12}
  ]

# from mix phx.gen.release
if System.get_env("PHX_SERVER") do
  config :qrstorage, QrstorageWeb.Endpoint, server: true
end
