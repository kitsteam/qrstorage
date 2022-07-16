defmodule Qrstorage.MixProject do
  use Mix.Project

  def project do
    [
      app: :qrstorage,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
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
      {:phoenix, "1.6.10"},
      {:phoenix_ecto, "4.4.0"},
      {:ecto_sql, "3.8.3"},
      {:postgrex, "0.16.3"},
      {:phoenix_html, "3.2.0"},
      {:phoenix_live_reload, "1.3.3", only: :dev},
      {:phoenix_live_dashboard, "0.6.5"},
      {:esbuild, "0.5.0", runtime: Mix.env() == :dev},
      {:dart_sass, "0.5.0", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "0.6.1"},
      {:telemetry_poller, "1.0.0"},
      {:gettext, "0.19.1"},
      {:timex, "3.7.8"},
      {:jason, "1.3.0"},
      {:plug_cowboy, "2.5.2"},
      {:httpoison, "1.8.1"},
      {:google_api_text_to_speech, "0.15.0"},
      {:goth, "1.2.0"},
      {:oban, "2.12.1"},
      {:json, "1.4.1"},
      {:fast_sanitize, "0.2.3"}
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
