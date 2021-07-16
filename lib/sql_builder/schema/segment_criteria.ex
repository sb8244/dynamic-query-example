defmodule SqlBuilder.Schema.SegmentCriteria do
  @moduledoc """
  Represents criteria for segments based on static values. Example:

  * widget.maker = "Acme"
  * widget.maker != "Acme"
  * widget.external_id = "1"

  The criteria values are strings in this implementation. It isn't really important here, because you
  could define the value polymorphically and do comparisons differently depending on the type.
  """

  use Ecto.Schema

  embedded_schema do
    field :object, :string, default: "widget"
    field :object_field, :string
    field :operator, :string, default: "="
    field :value, :string
  end

  @valid_objects ["widget", "creator"]
  def valid_objects, do: @valid_objects

  @valid_fields %{
    "widget" => ["name", "type", "external_id"],
    "creator" => ["name", "type", "external_id"]
  }

  def valid_fields(object) do
    Map.fetch!(@valid_fields, object)
  end
end
