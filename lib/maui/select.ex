defmodule Maui.Select do
  use Phoenix.Component

  attr :id, :string, required: true
  attr :options, :list, default: []
  attr :placeholder, :string, default: "Select an option"
  attr :class, :string, default: ""

  slot :inner_block

  def select(assigns) do
    ~H"""
    <div id={@id}  phx-hook="Maui.Select" class="relative">
        <button
        role="cobobox"
        class={["border-input data-placeholder:text-muted-foreground [&_svg:not([class*='text-'])]:text-muted-foreground focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive dark:bg-input/30 dark:hover:bg-input/50 flex w-fit items-center justify-between gap-2 rounded-md border bg-transparent px-3 py-2 text-sm whitespace-nowrap shadow-xs transition-[color,box-shadow] outline-none focus-visible:ring [3px] disabled:cursor-not-allowed disabled:opacity-50 data-[size=default]:h-9 data-[size=sm]:h-8 *:data-[slot=select-value]:line-clamp-1 *:data-[slot=select-value]:flex *:data-[slot=select-value]:items-center *:data-[slot=select-value]:gap-2 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"]}>
        Select an item
      </button>
    </div>
    """
  end

  @doc """
  Select Option
  """
  attr :value, :string, required: true

  def option(assigns) do
    ~H"""
    <div role="option" class="p-2 hover:bg-gray-100 cursor-pointer"></div>
    """
  end
end
