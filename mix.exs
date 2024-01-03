defmodule Qrstorage.MixProject do
  use Mix.Project

  def project do
    [
      app: :qrstorage,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
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
      {:phoenix, "1.6.16"},
      {:phoenix_ecto, "4.4.3"},
      {:ecto_sql, "3.11.1"},
      {:postgrex, "0.17.4"},
      {:phoenix_html, "3.2.0"},
      {:phoenix_live_reload, "1.3.3", only: :dev},
      {:phoenix_live_dashboard, "0.6.5"},
      {:esbuild, "0.5.0", runtime: Mix.env() == :dev},
      {:dart_sass, "0.5.0", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "0.6.1"},
      {:telemetry_poller, "1.0.0"},
      {:gettext, "0.24.0"},
      {:timex, "3.7.11"},
      {:jason, "1.4.1"},
      {:plug_cowboy, "2.6.1"},
      {:google_api_text_to_speech, "0.15.0"},
      {:google_api_translate, "0.15.0"},
      {:goth, "1.4.2"},
      {:oban, "2.17.1"},
      {:json, "1.4.1"},
      {:fast_sanitize, "0.2.3"},
      {:mox, "1.0.2", only: :test}
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
