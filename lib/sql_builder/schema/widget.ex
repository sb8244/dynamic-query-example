defmodule SqlBuilder.Schema.Widget do
  use Ecto.Schema

  schema "widgets" do
    field :name, :string
    field :type, :string
    field :external_id, :string

    belongs_to :creator, SqlBuilder.Schema.Creator

    timestamps()
  end
end
