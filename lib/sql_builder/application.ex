defmodule SqlBuilder.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      SqlBuilder.Repo,
      # Start the Telemetry supervisor
      SqlBuilderWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: SqlBuilder.PubSub},
      # Start the Endpoint (http/https)
      SqlBuilderWeb.Endpoint
      # Start a worker by calling: SqlBuilder.Worker.start_link(arg)
      # {SqlBuilder.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SqlBuilder.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SqlBuilderWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
