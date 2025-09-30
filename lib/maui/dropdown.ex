defmodule Maui.Dropdown do
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
      class={[
        "aria-hidden:hidden block bg-popover text-popover-foreground",
        "not-aria-hidden:animate-in aria-hidden:animate-out aria-hidden:fade-out-0 not-aria-hidden:fade-in-0 aria-hidden:zoom-out-95 not-aria-hidden:zoom-in-95",
        "data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2",
        "z-50  min-w-[8rem] overflow-x-hidden overflow-y-auto rounded-md border border-border p-1 shadow-md",
        "max-h-(--radix-dropdown-menu-content-available-height) origin-(--radix-dropdown-menu-content-transform-origin)",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  slot :inner_block
  attr :shortcut, :string, default: nil
  attr :variant, :string, default: "default", values: ["default", "destructive"]

  attr :rest, :global

  def menu_item(assigns) do
    ~H"""
    <div
      data-variant={@variant}
      role="menuitem"
      class={[
        "focus:bg-accent focus:text-accent-foreground hover:bg-accent hover:text-accent-foreground",
        "data-[variant=destructive]:text-destructive data-[variant=destructive]:focus:bg-destructive/10 dark:data-[variant=destructive]:focus:bg-destructive/20 data-[variant=destructive]:focus:text-destructive data-[variant=destructive]:*:[svg]:!text-destructive [&_svg:not([class*='text-'])]:text-muted-foreground",
        "relative flex cursor-default items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-hidden select-none",
        "data-[disabled]:pointer-events-none data-[disabled]:opacity-50 data-[inset]:pl-8 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
      <.menu_shortcut :if={@shortcut != nil}>
        {@shortcut}
      </.menu_shortcut>
    </div>
    """
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
