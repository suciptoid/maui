defmodule Maui.Dropdown do
  @moduledoc """
  Dropdown menu component for displaying actions and options.

  ## Basic Menu Button

      <.menu_button>
        Open Menu
        <:item>Profile</:item>
        <:item>Settings</:item>
        <:item variant="destructive">Delete</:item>
      </.menu_button>

  ## With Shortcuts

      <.menu_button content_class="w-52">
        <.icon name="hero-user" class="size-4" /> Account
        <:item shortcut="⌘P">Profile</:item>
        <:item shortcut="⌘S">Settings</:item>
        <:item shortcut="⇧⌘Q">Log out</:item>
      </.menu_button>

  ## With Links

      <.menu_button>
        Actions
        <:item navigate="/profile">View Profile</:item>
        <:item patch="/settings">Edit Settings</:item>
        <:item href="/logout">Sign Out</:item>
      </.menu_button>

  ## Custom Items

  For more control, use the `:items` slot with `menu_item`:

      <.menu_button content_class="w-56">
        Options
        <:items>
          <.menu_item navigate="/dashboard">
            <.icon name="hero-home" class="size-4" /> Dashboard
          </.menu_item>
          <.menu_separator />
          <.menu_item variant="destructive" phx-click="delete">
            <.icon name="hero-trash" class="size-4" /> Delete
          </.menu_item>
        </:items>
      </.menu_button>

  ## Destructive Actions

      <.menu_button>
        Danger Zone
        <:item variant="destructive" shortcut="⌘⌫">
          <.icon name="hero-trash" class="size-4" /> Delete Account
        </:item>
      </.menu_button>

  ## Attributes (menu_button/1)

  | Attribute | Type | Default | Description |
  |-----------|------|---------|-------------|
  | `variant` | `string` | `"secondary"` | Button variant style |
  | `content_class` | `string` | `""` | CSS classes for dropdown content |
  | `class` | `string` | `""` | Additional CSS classes for button |

  ## Slots (menu_button/1)

  | Slot | Description |
  |------|-------------|
  | `inner_block` | Button content (required) |
  | `item` | Menu items with optional attributes |
  | `items` | Custom menu content using `menu_item` |

  ## Item Attributes

  | Attribute | Type | Description |
  |-----------|------|-------------|
  | `variant` | `string` | Item style: "default" or "destructive" |
  | `shortcut` | `string` | Keyboard shortcut display |
  | `href` | `string` | Link URL |
  | `navigate` | `string` | Phoenix navigate path |
  | `patch` | `string` | Phoenix patch path |
  """

  use Phoenix.Component

  attr :variant, :string,
    default: "secondary",
    doc: "see Button variant"

  attr :rest, :global
  attr :content_class, :string, default: ""
  attr :class, :string, default: ""

  slot :item do
    attr :variant, :string
    attr :shortcut, :string
    attr :href, :string
    attr :navigate, :string
    attr :patch, :string
  end

  slot :items
  slot :inner_block

  def menu_button(%{rest: rest} = assigns) do
    id = rest[:id] || "dropdown-#{System.unique_integer([:positive])}"

    assigns = assign(assigns, id: id)

    ~H"""
    <div id={@id} class="w-fit" phx-hook="Maui.Popover">
      <Maui.Button.button
        id={"#{@id}-trigger"}
        variant={@variant}
        aria-haspopup="menu"
        aria-expanded="false"
        aria-controls={"#{@id}-listbox"}
        class={@class}
      >
        {render_slot(@inner_block)}
      </Maui.Button.button>
      <.menu_content id={"#{@id}-listbox"} class={@content_class}>
        <.menu_item
          :for={item <- @item}
          shortcut={Map.get(item, :shortcut)}
          variant={Map.get(item, :variant, "default")}
          href={Map.get(item, :href)}
          navigate={Map.get(item, :navigate)}
          patch={Map.get(item, :patch)}
        >
          {render_slot(item)}
        </.menu_item>
        {render_slot(@items)}
      </.menu_content>
    </div>
    """
  end

  attr :class, :string, default: ""
  attr :rest, :global
  slot :inner_block

  def menu_content(assigns) do
    ~H"""
    <div
      aria-hidden="true"
      role="listbox"
      class={
        [
          "aria-hidden:hidden block bg-popover text-popover-foreground",
          "not-aria-hidden:animate-in aria-hidden:animate-out aria-hidden:fade-out-0 not-aria-hidden:fade-in-0 aria-hidden:zoom-out-95 not-aria-hidden:zoom-in-95",
          "data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2",
          "z-50  min-w-32 overflow-x-hidden overflow-y-auto rounded-md border border-border p-1 shadow-md",
          # "max-h-(--radix-dropdown-menu-content-available-height) origin-(--radix-dropdown-menu-content-transform-origin)",
          @class
        ]
      }
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  slot :inner_block
  attr :shortcut, :string, default: nil
  attr :variant, :string, default: "default", values: ["default", "destructive"]

  attr :rest, :global, include: ~w(href navigate patch method download name value disabled)

  def menu_item(%{rest: rest} = assigns) do
    class = [
      "aria-selected:bg-accent aria-selected:text-accent-foreground",
      "focus:bg-accent focus:text-accent-foreground hover:bg-accent hover:text-accent-foreground",
      "data-[variant=destructive]:text-destructive data-[variant=destructive]:focus:bg-destructive/10 dark:data-[variant=destructive]:focus:bg-destructive/20 data-[variant=destructive]:focus:text-destructive data-[variant=destructive]:*:[svg]:text-destructive! [&_svg:not([class*='text-'])]:text-muted-foreground",
      "relative flex cursor-default items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-hidden select-none",
      "data-disabled:pointer-events-none data-disabled:opacity-50 data-inset:pl-8 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"
    ]

    assigns = assign(assigns, class: class)

    if rest[:href] || rest[:navigate] || rest[:patch] do
      ~H"""
      <.link data-variant={@variant} role="menuitem" class={@class} {@rest}>
        {render_slot(@inner_block)}
        <.menu_shortcut :if={@shortcut != nil}>
          {@shortcut}
        </.menu_shortcut>
      </.link>
      """
    else
      ~H"""
      <div
        data-variant={@variant}
        role="menuitem"
        class={@class}
        {@rest}
      >
        {render_slot(@inner_block)}
        <.menu_shortcut :if={@shortcut != nil}>
          {@shortcut}
        </.menu_shortcut>
      </div>
      """
    end
  end

  slot :inner_block
  attr :rest, :global
  attr :class, :string, default: ""

  def menu_shortcut(assigns) do
    ~H"""
    <span
      class={["text-muted-foreground ml-auto text-xs tracking-widest", @class]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </span>
    """
  end

  def menu_separator(assigns) do
    ~H"""
    <div role="separator" aria-orientation="horizontal" class="bg-border -mx-1 my-1 h-px"></div>
    """
  end
end
