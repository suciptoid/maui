defmodule Maui.Popover do
  use Phoenix.Component

  @doc """
  Popover primitive
  """
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
      phx-hook="Maui.Tooltip">

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

        <div data-arrow class="absolute bg-foreground fill-foreground z-50 size-2.5 rotate-45 rounded-[2px]">
        </div>

      </div>
    </div>
    """
  end
end
