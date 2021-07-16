defmodule SqlBuilderWeb.Component do
  use SqlBuilderWeb, :live_component

  def render(assigns) do
    ~L"""
    <div>Component</div>
    <button phx-click="add" phx-target="<%= @myself %>">Add</button>

    <div style="padding-left: 10px;">
      <%= for id <- @list do %>
        <%= live_component @socket, __MODULE__, id: id %>
      <% end %>
    </div>
    """
  end

  def update(assigns, socket) do
    {:ok, assign(socket, list: [])}
  end

  def handle_event("add", _, socket) do
    {:noreply, assign(socket, list: [:erlang.unique_integer | socket.assigns.list])}
  end
end
