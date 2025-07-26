defmodule MAUI.Popover do
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
end
