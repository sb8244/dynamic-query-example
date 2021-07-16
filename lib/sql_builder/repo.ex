defmodule SqlBuilder.Repo do
  use Ecto.Repo,
    otp_app: :sql_builder,
    adapter: Ecto.Adapters.Postgres
end
