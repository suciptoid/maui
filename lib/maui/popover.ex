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
      class="w-fit"
      data-placement={@placement}
      phx-hook="Maui.Tooltip">

      {render_slot(@inner_block)}

      <div
        :if={@tooltip != []}
        role="tooltip"
        id={"#{@id}-tooltip"}
        aria-hidden="true"
        class={[
          "bg-foreground text-background duration-200 transition-all",
          "z-50 w-fit rounded-md px-3 py-1.5 text-sm text-balance",
          "not-aria-hidden:block aria-hidden:hidden",
          "animate-in zoom-in-95 fade-in-0",
          "data-[placement=top]:text-xl",
          "aria-hidden:animate-out aria-hidden:fade-out-0 aria-hidden:zoom-out-95",
          "data-[placement=bottom]:slide-in-from-top data-[placement=left]:slide-in-from-right data-[placement=right]:slide-in-from-left data-[placement=top]:slide-in-from-bottom",
          # "origin-(--radix-tooltip-content-transform-origin) data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95 data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2",
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
