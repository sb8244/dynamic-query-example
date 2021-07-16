defmodule SqlBuilder.SegmentEvaluator do
  import Ecto.Query
  alias SqlBuilder.Schema.{SegmentCriteria, SegmentLogic}

  @doc """
  Returns a Ecto.Query.dynamic that can be used as conditions for a widget_creator query.
  """
  def to_sql(logic = %SegmentLogic{}) do
    sql_combine(logic.connective, sql_logic(logic), sql_criteria(logic))
  end

  # Combine all of the sub-logic using the connective of the parent
  defp sql_logic(%SegmentLogic{connective: connective, segment_logic: logic}) do
    Enum.reduce(logic, nil, fn child_logic = %SegmentLogic{}, q ->
      child_query = to_sql(child_logic)
      sql_combine(connective, q, child_query)
    end)
  end

  # Combine all of the criteria using the connective of the logic
  defp sql_criteria(%SegmentLogic{connective: connective, segment_criteria: criteria}) do
    Enum.reduce(criteria, nil, fn c = %SegmentCriteria{}, q ->
      sql_combine(connective, q, gen_criteria(c))
    end)
  end

  # There may be a way to avoid needing to specify different functions for the different objects (named bindings?)
  # However, for 2 it isn't really a big deal.
  defp gen_criteria(%SegmentCriteria{object: "widget", object_field: field, operator: operator, value: value}) do
    field_name = String.to_atom(field)

    # Only these simple operators are provided for demonstration purposes. I could see other operators being included,
    # like contains, does not contain, etc.
    case operator do
      "=" -> dynamic([w], field(w, ^field_name) == ^value)
      "!=" -> dynamic([w], field(w, ^field_name) != ^value)
    end
  end

  defp gen_criteria(%SegmentCriteria{object: "creator", object_field: field, operator: operator, value: value}) do
    field_name = String.to_atom(field)

    case operator do
      "=" -> dynamic([w, c], field(c, ^field_name) == ^value)
      "!=" -> dynamic([w, c], field(c, ^field_name) != ^value)
    end
  end

  # If there is no logic/criteria to check, then we assume that access is allowed
  defp sql_combine(_connective, nil, nil), do: dynamic(true)

  # If there's no left or right condition, then there is no logic to apply
  # This greatly simplifies the end result, versus passing "true AND" / "false OR" throughout the code
  defp sql_combine(_connective, nil, right), do: right
  defp sql_combine(_connective, left, nil), do: left

  defp sql_combine(connective, left, right) do
    case connective do
      "OR" -> dynamic([], ^left or ^right)
      "AND" -> dynamic([], ^left and ^right)
    end
  end
end
