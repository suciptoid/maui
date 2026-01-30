defmodule Maui.MenuButton do
  @moduledoc """
  A button that opens a popup menu. Built on top of Popover.

  ## Basic Usage

      <.button id="menu-1">
        <:button>Open Menu</:button>
        <:popup>
          <.menu_item>Item 1</.menu_item>
          <.menu_item>Item 2</.menu_item>
        </:popup>
      </.button>

  ## With Custom Styling

      <.button id="menu-2">
        <:button class="bg-blue-500 text-white">Options</:button>
        <:popup class="p-4 bg-popover rounded-lg shadow-lg">
          <.menu_item phx-click="action-1">Action 1</.menu_item>
          <.menu_item phx-click="action-2">Action 2</.menu_item>
        </:popup>
      </.button>

  ## Menu Grouping

      <.button id="menu-3">
        <:button>Settings</:button>
        <:popup>
          <.menu_group>
            <p class="px-2 py-1 text-xs font-semibold text-muted-foreground">Account</p>
            <.menu_item>Profile</.menu_item>
            <.menu_item>Security</.menu_item>
          </.menu_group>
          <.menu_group>
            <p class="px-2 py-1 text-xs font-semibold text-muted-foreground">Preferences</p>
            <.menu_item>Notifications</.menu_item>
            <.menu_item>Display</.menu_item>
          </.menu_group>
        </:popup>
      </.button>

  ## Attributes (button/1)

  | Attribute | Type | Default | Description |
  |-----------|------|---------|-------------|
  | `id` | `string` | required | Unique identifier |

  ## Slots (button/1)

  | Slot | Description |
  |------|-------------|
  | `button` | The trigger button content |
  | `popup` | The popup menu content |

  ## Menu Item

  Individual clickable menu items:

      <.menu_item phx-click="save">Save</.menu_item>
      <.menu_item role="menuitem">Profile</.menu_item>

  ## Menu Group

  Group related menu items:

      <.menu_group>
        <.menu_item>Item 1</.menu_item>
        <.menu_item>Item 2</.menu_item>
      </.menu_group>
  """

  use Phoenix.Component

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
