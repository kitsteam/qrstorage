defmodule Qrstorage.MixProject do
  use Mix.Project

  def project do
    [
      app: :qrstorage,
      version: "0.6.0",
      elixir: "~> 1.20",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      compilers: [:phoenix_live_view] ++ Mix.compilers(),
      deps: deps(),
      listeners: [Phoenix.CodeReloader]
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
      {:phoenix, "1.8.16"},
      {:phoenix_ecto, "4.7.0"},
      {:ecto_sql, "3.14.0"},
      {:postgrex, "0.22.4"},
      {:phoenix_html, "4.4.0"},
      {:phoenix_html_helpers, "1.0.1"},
      {:phoenix_view, "2.0.4"},
      {:phoenix_live_reload, "1.7.0", only: :dev},
      {:phoenix_live_dashboard, "0.9.1"},
      {:phoenix_live_view, "1.2.13"},
      {:lazy_html, "0.1.14", only: :test},
      {:esbuild, "0.10.1", runtime: Mix.env() == :dev},
      {:dart_sass, "0.8.0", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "1.2.0"},
      {:telemetry_poller, "1.3.0"},
      {:gettext, "1.0.2"},
      {:timex, "4.0.0"},
      {:jason, "1.4.5"},
      {:plug_cowboy, "2.9.0"},
      {:cowboy, "2.21.0"},
      {:oban, "2.24.2"},
      {:fast_sanitize, "0.2.3"},
      {:fast_html, "2.5.0"},
      {:mox, "1.3.2", only: :test},
      {:logger_json, "7.0.4"},
      {:ex_aws, "2.7.0"},
      {:ex_aws_s3, "2.5.9"},
      {:cloak, "1.1.4"},
      {:sobelow, "0.18.1", only: [:dev, :test], runtime: false},
      {:deepl_ex, "0.4.0"},
      {:tesla, "1.23.0"},
      {:hackney, "4.10.2"},
      {:tzdata, "1.2.2"},
      {:ex_url, "2.0.3"}
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
