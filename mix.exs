defmodule Qrstorage.MixProject do
  use Mix.Project

  def project do
    [
      app: :qrstorage,
      version: "0.5.2",
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Qrstorage.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "1.7.21"},
      {:phoenix_ecto, "4.6.3"},
      {:ecto_sql, "3.12.1"},
      {:postgrex, "0.20.0"},
      {:phoenix_html, "4.2.1"},
      {:phoenix_html_helpers, "1.0.1"},
      {:phoenix_view, "2.0.4"},
      {:phoenix_live_reload, "1.6.0", only: :dev},
      {:phoenix_live_dashboard, "0.8.6"},
      {:esbuild, "0.9.0", runtime: Mix.env() == :dev},
      {:dart_sass, "0.7.0", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "1.0.0"},
      {:telemetry_poller, "1.2.0"},
      {:gettext, "0.26.2"},
      {:timex, "3.7.11"},
      {:jason, "1.4.4"},
      {:plug_cowboy, "2.7.3"},
      {:cowboy, "2.13.0"},
      {:oban, "2.19.4"},
      {:fast_sanitize, "0.2.3"},
      {:fast_html, "2.4.1"},
      {:mox, "1.2.0", only: :test},
      {:logger_json, "7.0.2"},
      {:ex_aws, "2.5.8"},
      {:ex_aws_s3, "2.5.6"},
      {:cloak, "1.1.4"},
      {:sobelow, "0.13.0", only: [:dev, :test], runtime: false},
      {:deepl_ex, "0.4.0"},
      {:tesla, "1.14.1"},
      {:tzdata, "1.1.3"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": [
        "esbuild default --minify",
        "sass default --no-source-map --style=compressed",
        "phx.digest"
      ]
    ]
  end
end
