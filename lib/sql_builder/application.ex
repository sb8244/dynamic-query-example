defmodule SqlBuilder.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      SqlBuilder.Repo,
      SqlBuilderWeb.Telemetry,
      {Phoenix.PubSub, name: SqlBuilder.PubSub},
      SqlBuilderWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: SqlBuilder.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    SqlBuilderWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
