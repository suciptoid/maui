defmodule AppWeb.Live.DemoPopover do
  use AppWeb, :live_view
  use Maui

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(counter: 1)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("click", _, socket) do
    {:noreply, socket |> assign(counter: socket.assigns.counter + 1)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.docs flash={@flash} live_action={@live_action}>
      <div class="space-y-6">
        <div>
          <h2 class="text-lg font-semibold mb-4">Base Popover</h2>
          <p class="text-muted-foreground">
            Popover components that use Floating UI for positioning.
          </p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <.popover_base
            id="demo-popover-base"
            class="w-fit"
            phx-hook="Maui.Popover"
            data-placement="top"
          >
            <.button phx-click="click" aria-haspopup="menu">
              Click Me ({@counter})
            </.button>

            <:popup class="aria-hidden:hidden block min-w-[250px] bg-foreground text-primary-foreground rounded-md shadow-md border border-base-300 p-4">
              <div class="space-y-2">
                <p class="font-medium">Popover Content</p>
                <p class="text-sm opacity-90">This is a popover with custom content.</p>
                <.button aria-haspopup="menu" role="combobox" size="sm">
                  Action Button
                </.button>
              </div>
            </:popup>
          </.popover_base>
        </div>
      </div>
      <div class="h-10"></div>

      <div class="grid grid-cols-8 gap-4">
        <.tooltip id="toltip-icon-left" class="max-w-[200px]" placement="left">
          <.icon name="hero-arrow-left" class="w-4 h-4" />
          <:tooltip>
            Aku adalah tooltip, tooltip yang sangatt panjang
          </:tooltip>
        </.tooltip>
        <.tooltip id="toltip-icon-rith" class="max-w-[200px]" placement="right">
          <.icon name="hero-arrow-right" class="w-4 h-4" />
          <:tooltip>
            Aku adalah tooltip, tooltip yang sangatt panjang
          </:tooltip>
        </.tooltip>
        <.tooltip id="toltip-icon" class="max-w-[200px]" placement="bottom">
          <.button variant="secondary" size="icon" phx-click="click">
            <.icon name="hero-arrow-down" class="w-4 h-4" />
          </.button>
          <:tooltip>
            Aku adalah tooltip, tooltip yang sangatt panjang
          </:tooltip>
        </.tooltip>
        <.tooltip id="toltip" class="max-w-[200px]">
          <.button variant="secondary" phx-click="click">
            Hover Me ({@counter})
          </.button>
          <:tooltip>
            Aku adalah tooltip, tooltip yang sangatt panjang counter: {@counter}
          </:tooltip>
        </.tooltip>
        <.tooltip id="toltip-icon-withcontent" class="max-w-[200px] p-0!" placement="bottom">
          <.button variant="secondary" size="icon" phx-click="click">
            <.icon name="hero-arrow-down" class="w-4 h-4" />
          </.button>
          <:tooltip>
            <div class="w-200 min-h-[200px]">
              <img src="https://placehold.co/200x200" class="rounded-t-md" />
              <div class="p-2">
                This is just image placeholder tooltip
              </div>
            </div>
          </:tooltip>
        </.tooltip>
      </div>
      <div class="h-10"></div>
      <.button variant="secondary" phx-click="click">
        Increment ({@counter})
      </.button>
    </Layouts.docs>
    """
  end
end
