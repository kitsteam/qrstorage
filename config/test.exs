import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :qrstorage, Qrstorage.Repo,
  username: System.get_env("DATABASE_USER"),
  password: System.get_env("DATABASE_USER_PASSWORD"),
  database: "#{System.get_env("DATABASE_NAME")}#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: System.get_env("DATABASE_HOST"),
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :qrstorage, QrstorageWeb.Endpoint,
  http: [
    port: 4002
  ],
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# we configure ex_aws to localhost just to be sure that no test requests end up at aws:
config(:ex_aws, :s3,
  scheme: "https",
  host: "localhost",
  port: "443",
  region: "eu01",
  access_key_id: "access_key_id",
  secret_access_key: "secret_access_key"
)

config :qrstorage, Oban, repo: Qrstorage.Repo, testing: :inline
