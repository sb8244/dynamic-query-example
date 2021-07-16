defmodule SqlBuilder.Schema.Segment do
  use Ecto.Schema

  alias SqlBuilder.Schema.SegmentLogic

  schema "segments" do
    field :name, :string
    embeds_one :segment_logic, SegmentLogic, on_replace: :delete

    timestamps()
  end
end
