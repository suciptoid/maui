defmodule Maui.Popover do
  @moduledoc """
  Popover and tooltip components using Floating UI for positioning.

  ## Base Popover

  The base popover provides low-level building blocks for custom popover UIs:

      <.popover_base
        id="my-popover"
        phx-hook="Maui.Popover"
        data-placement="bottom"
      >
        <.button aria-haspopup="menu">Click Me</.button>

        <:popup class="aria-hidden:hidden block p-4 bg-popover rounded-md shadow-md">
          <p>Popover content here</p>
        </:popup>
      </.popover_base>

  ## Tooltip

  Tooltips appear on hover with configurable placement:

      <.tooltip id="tooltip-1" placement="top">
        <.button>Hover me</.button>
        <:tooltip>This is a tooltip</:tooltip>
      </.tooltip>

  ### Placement Options

      <.tooltip placement="top">...</.tooltip>
      <.tooltip placement="bottom">...</.tooltip>
      <.tooltip placement="left">...</.tooltip>
      <.tooltip placement="right">...</.tooltip>

  ## With Icons

      <.tooltip id="icon-tooltip" placement="bottom">
        <.icon name="hero-information-circle" class="size-5" />
        <:tooltip>More information about this</:tooltip>
      </.tooltip>

  ## Rich Content

      <.tooltip id="rich-tooltip">
        <.button>Hover for details</.button>
        <:tooltip>
          <div class="w-[200px]">
            <img src="..." class="rounded-t-md" />
            <div class="p-2">
              <p class="font-medium">Title</p>
              <p class="text-sm">Description text</p>
            </div>
          </div>
        </:tooltip>
      </.tooltip>

  ## Attributes (base/1)

  | Attribute | Type | Default | Description |
  |-----------|------|---------|-------------|
  | `id` | `string` | required | Unique identifier |
  | `hook` | `string` | `"Popover"` | Phoenix hook name |

  ## Attributes (tooltip/1)

  | Attribute | Type | Default | Description |
  |-----------|------|---------|-------------|
  | `id` | `string` | auto-generated | Unique identifier |
  | `placement` | `string` | `"top"` | Tooltip position |
  | `class` | `string` | `""` | Additional CSS classes |

  ## Slots (base/1)

  | Slot | Description |
  |------|-------------|
  | `trigger` | The element that triggers the popover |
  | `popup` | The popover content |
  | `inner_block` | Alternative to trigger slot |

  ## Slots (tooltip/1)

  | Slot | Description |
  |------|-------------|
  | `inner_block` | The element that triggers the tooltip |
  | `tooltip` | The tooltip content |
  """

  use Phoenix.Component

  attr :id, :string, required: true
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"
  attr :hook, :string, default: "Popover"

  slot :trigger, doc: "Trigger for the popover" do
    attr :class, :string, doc: "Trigger class"
    attr :role, :string, doc: "Trigger aria role"
  end

  slot :popup, doc: "Popup for the popover" do
    attr :class, :string, doc: "Popup class"
    attr :role, :string, doc: "Popup role"
  end

  slot :inner_block,
    doc: "Inner block / children for the popover, can be used for non <button> custom trigger "

  def base(assigns) do
    ~H"""
    <div id={@id} {@rest}>
      <%!-- Trigger --%>
      <button
        :for={t <- @trigger}
        type="button"
        class={Map.get(t, :class, "")}
        role={Map.get(t, :role, "combobox")}
        id={"#{@id}-trigger"}
        aria-controls={"#{@id}-listbox"}
        aria-haspopup="listbox"
        aria-expanded="false"
      >
        {render_slot(t)}
      </button>
      <%= if @trigger == [] do %>
        {render_slot(@inner_block)}
      <% end %>
      <%!-- Popover --%>
      <div
        :for={p <- @popup}
        id={"#{@id}-popover"}
        role={Map.get(p, :role, "listbox")}
        aria-hidden="true"
        class={Map.get(p, :class, "")}
      >
        {render_slot(p)}
      </div>
    </div>
    """
  end

  @doc """

  """
  attr :id, :string
  attr :class, :string, default: ""
  attr :placement, :string, values: ["top", "bottom", "left", "right"], default: "top"
  slot :inner_block

  slot :tooltip do
    attr :class, :string
  end

  def tooltip(assigns) do
    assigns = assign_new(assigns, :id, fn -> "tooltip#{System.unique_integer()}" end)

    ~H"""
    <div
      id={@id}
      class="w-fit group"
      data-placement={@placement}
      phx-hook="Maui.Tooltip"
    >
      {render_slot(@inner_block)}

      <div
        :if={@tooltip != []}
        role="tooltip"
        id={"#{@id}-tooltip"}
        aria-hidden="true"
        data-placement={@placement}
        class={[
          "bg-foreground text-background",
          "duration-100 transition ease-in transform",
          "data-[placement=top]:translate-y-0 data-[placement=top]:aria-hidden:translate-y-2",
          "data-[placement=bottom]:translate-y-0 data-[placement=bottom]:aria-hidden:-translate-y-2",
          "data-[placement=right]:translate-x-0 data-[placement=right]:aria-hidden:-translate-x-2",
          "data-[placement=left]:translate-x-0 data-[placement=left]:aria-hidden:translate-x-2",
          "opacity-100 aria-hidden:opacity-0",
          "aria-hidden:pointer-events-none",
          "invisible not-aria-hidden:visible",
          "z-50 w-fit rounded-md px-3 py-1.5 text-sm text-balance",
          @class
        ]}
      >
        {render_slot(@tooltip)}

        <div
          data-arrow
          class="absolute bg-foreground fill-foreground z-[-1] size-2.5 rotate-45 rounded-[2px]"
        >
        </div>
      </div>
    </div>
    """
  end
end
