defmodule SqlBuilder.Schema.Creator do
  use Ecto.Schema

  schema "creators" do
    field :name, :string
    field :type, :string
    field :external_id, :string

    has_many :widgets, SqlBuilder.Schema.Widget

    timestamps()
  end
end
