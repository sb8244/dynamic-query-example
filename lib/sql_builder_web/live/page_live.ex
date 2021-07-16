defmodule SqlBuilderWeb.PageLive do
  use SqlBuilderWeb, :live_view

  def render(assigns) do
    ~L"""
    <%= live_component @socket, SqlBuilderWeb.Component, id: "root" %>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
