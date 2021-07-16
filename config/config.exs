# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :sql_builder,
  ecto_repos: [SqlBuilder.Repo]

# Configures the endpoint
config :sql_builder, SqlBuilderWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "csnZij4dDLOgmY8FIUrJOz09ZZuP7+1TjreGpBF0lmp9zUjEUdmRHzJNj/pD+CmQ",
  render_errors: [view: SqlBuilderWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: SqlBuilder.PubSub,
  live_view: [signing_salt: "m7vMHeum"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
