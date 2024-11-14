defmodule LiveViewBack.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LiveViewBackWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:live_view_back, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: LiveViewBack.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: LiveViewBack.Finch},
      # Start a worker by calling: LiveViewBack.Worker.start_link(arg)
      # {LiveViewBack.Worker, arg},
      # Start to serve requests, typically the last entry
      LiveViewBackWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveViewBack.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LiveViewBackWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
