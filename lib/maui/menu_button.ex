defmodule Maui.MenuButton do
  use Phoenix.Component

  @doc """

  """
  attr :id, :string, required: true

  slot :button do
    attr :class, :string
  end

  slot :popup, required: true do
    attr :class, :string
  end

  def button(assigns) do
    popup = List.first(assigns[:popup] || []) || %{}
    assigns = assigns |> assign(popup: popup)

    ~H"""
    <Maui.Popover.base id={@id} phx-hook="Popover" class="relative">
      <:trigger :for={button <- @button} class={Map.get(button, :class, "")}>
        {render_slot(button)}
      </:trigger>

      <:popup class={Map.get(@popup, :class, "")} role="menu">
        {render_slot(@popup)}
      </:popup>
    </Maui.Popover.base>
    """
  end

  attr :rest, :global

  @doc """
  Menu item
  """
  slot :inner_block, required: true

  def menu_item(assigns) do
    ~H"""
    <button role="menuitem" {@rest}>
      {render_slot(@inner_block)}
    </button>
    """
  end

  @doc """
  Menu group
  """
  def menu_group(assigns) do
    ~H"""
    <div role="group">
      {render_slot(@inner_block)}
    </div>
    """
  end
end
