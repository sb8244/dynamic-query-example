defmodule SqlBuilder do
  import Ecto.Query

  alias SqlBuilder.Schema.Widget

  def widget_creator_query do
    from(
      w in Widget,
      join: c in assoc(w, :creator)
    )
  end
end
