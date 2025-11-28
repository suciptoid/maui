defmodule AppWeb.Live.LiveComponent do
  use Phoenix.LiveComponent

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1>Hello, World! from live component</h1>
    </div>
    """
  end
end
