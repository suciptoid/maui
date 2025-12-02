defmodule Maui.Select do
  use Phoenix.Component
  import Maui.Input, only: [label: 1]

  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :value, :string, default: nil
  attr :placeholder, :string, default: "Select an item"
  attr :options, :list, default: []
  attr :searchable, :boolean, default: false
  attr :class, :string, default: "w-fit"
  attr :label, :string, default: nil

  attr :field, Phoenix.HTML.FormField,
    default: nil,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  slot :inner_block
  slot :header
  slot :footer

  def select(%{label: label} = assigns) when label not in ["", nil] do
    assigns = map_field(assigns)

    ~H"""
    <div class="grid w-full items-center gap-3">
      <.label for={@id}>{@label}</.label>
      <.select {assigns |> Map.delete(:label)} />
    </div>
    """
  end

  def select(%{options: options} = assigns) when options != [] do
    assigns =
      assigns
      |> map_field()
      |> assign(options: normalize_options(options))
      |> map_placeholder()

    ~H"""
    <.select
      id={@id}
      name={@name}
      class={@class}
      value={@value}
      placeholder={@placeholder}
      searchable={@searchable}
    >
      <%= for opt <- @options do %>
        <%= case opt do %>
          <% {:group, group_label} -> %>
            <div class="px-2 py-1 text-xs font-semibold text-muted-foreground">{group_label}</div>
          <% {val, label} -> %>
            <.select_item value={val}>{label}</.select_item>
        <% end %>
      <% end %>
    </.select>
    """
  end

  def select(assigns) do
    assigns = map_field(assigns)

    ~H"""
    <div
      id={@id}
      data-value={@value}
      phx-hook="Maui.Select"
      class="relative"
    >
      <input type="hidden" name={@name} value={@value} />
      <button
        type="button"
        role="combobox"
        class={[
          "border-input data-placeholder:text-muted-foreground [&_svg:not([class*='text-'])]:text-muted-foreground focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive dark:bg-input/30 dark:hover:bg-input/50 flex items-center justify-between gap-2 rounded-md border bg-transparent px-3 py-2 text-sm whitespace-nowrap shadow-xs transition-[color,box-shadow] outline-none focus-visible:ring [3px] disabled:cursor-not-allowed disabled:opacity-50 data-[size=default]:h-9 data-[size=sm]:h-8 *:data-[slot=select-value]:line-clamp-1 *:data-[slot=select-value]:flex *:data-[slot=select-value]:items-center *:data-[slot=select-value]:gap-2 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4",
          @class
        ]}
      >
        <span data-maui="selected-label">
          {@placeholder}
        </span>
        <.select_icon class="ml-2 h-4 w-4 shrink-0 opacity-50" />
      </button>

      <div
        role="listbox"
        aria-hidden="true"
        class={[
          "aria-hidden:hidden block bg-popover text-popover-foreground",
          "not-aria-hidden:animate-in aria-hidden:animate-out aria-hidden:fade-out-0 not-aria-hidden:fade-in-0 aria-hidden:zoom-out-95 not-aria-hidden:zoom-in-95",
          "data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2",
          "z-50 min-w-52 overflow-x-hidden overflow-y-auto rounded-md border border-border shadow-md",
          "max-h-(--radix-dropdown-menu-content-available-height) origin-(--radix-dropdown-menu-content-transform-origin)"
        ]}
      >
        {render_slot(@header)}

        <.select_search :if={@searchable} />

        <div data-maui="menu-items">
          {render_slot(@inner_block)}
        </div>

        {render_slot(@footer)}
      </div>
    </div>
    """
  end

  def select_search(assigns) do
    ~H"""
    <div data-maui="combobox-search" class="flex h-9 items-center gap-2 border-b px-3">
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="24"
        height="24"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
        class="lucide lucide-search size-4 shrink-0 opacity-50"
      >
        <circle cx="11" cy="11" r="8"></circle>
        <path d="m21 21-4.3-4.3"></path>
      </svg>
      <input
        class="placeholder:text-muted-foreground flex w-full rounded-md bg-transparent py-3 text-sm outline-hidden disabled:cursor-not-allowed disabled:opacity-50 h-9"
        placeholder="Search item..."
        autocomplete="off"
        autocorrect="off"
        spellcheck="false"
        aria-autocomplete="list"
        role="combobox"
        aria-expanded="true"
        type="text"
        value=""
      />
    </div>
    """
  end

  attr :value, :string, required: true
  slot :inner_block

  def select_item(assigns) do
    ~H"""
    <div
      role="menuitem"
      data-value={@value}
      class={[
        "aria-hidden:hidden",
        "focus:bg-accent focus:text-accent-foreground hover:bg-accent hover:text-accent-foreground aria-selected:bg-accent aria-selected:text-accent-foreground",
        "data-[variant=destructive]:text-destructive data-[variant=destructive]:focus:bg-destructive/10 dark:data-[variant=destructive]:focus:bg-destructive/20 data-[variant=destructive]:focus:text-destructive data-[variant=destructive]:*:[svg]:!text-destructive [&_svg:not([class*='text-'])]:text-muted-foreground",
        "relative flex cursor-default items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-hidden select-none",
        "data-disabled:pointer-events-none data-disabled:opacity-50 data-inset:pl-8 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"
      ]}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :rest, :global

  def select_icon(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      {@rest}
    >
      <path d="m7 15 5 5 5-5" /><path d="m7 9 5-5 5 5" />
    </svg>
    """
  end

  defp normalize_options(options) when is_list(options) do
    options
    |> Enum.flat_map(&normalize_option/1)
  end

  defp normalize_option({group_name, group_items}) when is_list(group_items) do
    header = {:group, to_string(group_name)}

    items =
      group_items
      |> Enum.map(&normalize_single/1)

    [header | items]
  end

  defp normalize_option({v, l}) do
    [{to_string(v), to_string(l)}]
  end

  defp normalize_option(item) do
    [normalize_single(item)]
  end

  defp normalize_single({v, l}) do
    {to_string(v), to_string(l)}
  end

  defp normalize_single(%{value: v, label: l}) do
    {to_string(v), to_string(l)}
  end

  defp normalize_single(%{value: v}) do
    s = to_string(v)
    {s, s}
  end

  defp normalize_single(%{label: l}) do
    s = to_string(l)
    {s, s}
  end

  defp normalize_single(item) when is_binary(item) or is_atom(item) or is_number(item) do
    s = to_string(item)
    {s, s}
  end

  defp normalize_single(item) do
    s = to_string(item)
    {s, s}
  end

  defp map_placeholder(assigns) do
    selected = assigns[:value]

    placeholder =
      if selected && selected != "" do
        # search flattened options for a pair matching the selected value
        case Enum.find(assigns.options, fn
               {:group, _} -> false
               {v, _label} -> v == to_string(selected)
             end) do
          nil -> assigns[:placeholder]
          {_v, label} -> label
        end
      else
        assigns[:placeholder]
      end

    assign(assigns, placeholder: placeholder)
  end

  def map_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(:id, assigns.id || field.id)
    |> assign(:name, assigns.name || field.name)
    |> assign(:value, assigns.value || field.value)
    |> assign(:field, nil)
  end

  def map_field(assigns) do
    assigns
  end
end
