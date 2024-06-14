defmodule Qrstorage.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    Oban.Telemetry.attach_default_logger()

    children = [
      # Start the Ecto repository
      Qrstorage.Repo,
      # Start the Telemetry supervisor
      QrstorageWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Qrstorage.PubSub},
      # Start the Endpoint (http/https)
      QrstorageWeb.Endpoint,
      Qrstorage.Services.Vault,
      {Oban, oban_config()}
    ]

    children =
      if Application.get_env(:goth, :disabled, false),
        do: children,
        else: [{Goth, name: Qrstorage.Goth, source: goth_config()} | children]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Qrstorage.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    QrstorageWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp oban_config do
    Application.get_env(:qrstorage, Oban)
  end

  defp goth_config do
    credentials = Application.get_env(:qrstorage, :gcp_credentials)
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    {:service_account, credentials, scopes: scopes}
  end
end
