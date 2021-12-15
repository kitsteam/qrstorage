import Config
require Logger

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

config :qrstorage, Qrstorage.Repo,
  url: System.get_env("DATABASE_URL"),
  username: System.get_env("DATABASE_USER"),
  password: System.get_env("DATABASE_USER_PASSWORD"),
  database: System.get_env("DATABASE_NAME"),
  hostname: System.get_env("DATABASE_HOST"),
  port: String.to_integer(System.get_env("DATABASE_PORT", "5432")),
  pool_size: String.to_integer(System.get_env("POOL_SIZE", "15")),
  ssl: System.get_env("DATABASE_SSL", "true") == "true"

# Set possible translations
default_locale =
  case config_env() do
    :test -> "en"
    _ -> String.trim(System.get_env("QR_CODE_DEFAULT_LOCALE") || "de")
  end

config :gettext, :default_locale, default_locale
config :timex, :default_locale, default_locale

if gcp_config = System.get_env("GCP_CONFIG_PATH") do
  Logger.info("Loading GCP Config file: #{gcp_config}")
  config :goth, json: gcp_config |> File.read!()
else
  Logger.warn("""
  Environment variable GCP_CONFIG_PATH is missing or empty.
  For example: ./gcp-config.json
  """)
end

# Here some environment specific configurations
if config_env() == :test do
  config :qrstorage, Qrstorage.Repo,
    database: "#{System.get_env("DATABASE_NAME")}_test#{System.get_env("MIX_TEST_PARTITION")}"
end

if config_env() == :prod || config_env() == :dev do
  config :qrstorage, Oban,
    repo: Qrstorage.Repo,
    plugins: [
      {Oban.Plugins.Cron,
       crontab: [
         {"@midnight", Qrstorage.Worker.RemoveCodesWorker}
       ]}
    ],
    queues: [default: 5]
end
