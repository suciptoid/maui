defmodule MAUI.Select do
  use Phoenix.Component

  attr :id, :string, required: true
  attr :options, :list, default: []
  attr :placeholder, :string, default: "Select an option"
  attr :class, :string, default: ""

  slot :inner_block

  def select(assigns) do
    ~H"""
    <MAUI.Popover.base id={@id} phx-hook="Select" class="relative">
      <:trigger class={@class}>
        {@placeholder}
      </:trigger>
      <:popup class="aria-hidden:hidden min-w-[250px] h-[300px] rounded-md shadow-md border border-gray-100 bg-white absolute top-10 z-10">
      </:popup>
    </MAUI.Popover.base>
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
