defmodule SqlBuilder.Schema.SegmentLogic do
  @moduledoc """
  Combines multiple logic/criteria clauses together. This forms a recursive tree that we can parse to reconstruct
  the logic statement. The tree must always resolve by a single root node, or there will be ambiguity in
  the logic.
  """

  use Ecto.Schema

  alias SqlBuilder.Schema.SegmentCriteria

  embedded_schema do
    field :connective, :string, default: "AND"

    embeds_many :segment_logic, __MODULE__, on_replace: :delete
    embeds_many :segment_criteria, SegmentCriteria, on_replace: :delete
  end
end
