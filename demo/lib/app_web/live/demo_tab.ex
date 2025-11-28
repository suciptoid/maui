defmodule AppWeb.Live.DemoTab do
  use AppWeb, :live_view
  use Maui

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(count: 0)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("incr", _, socket) do
    {:noreply, socket |> assign(count: socket.assigns.count + 1)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.docs flash={@flash} live_action={@live_action}>
      <h1>Demo Tab</h1>
      <div id="tab-hok" phx-hook=".TabHook">
        <.button phx-click="incr">
          Incr {@count}
        </.button>
      </div>

      <script :type={Phoenix.LiveView.ColocatedHook} name=".TabHook">
        export default {
          mounted() {
            console.log("tabhook mounted")
          },

          beforeUpdate(from, to) {
            console.log("hook updated", {from, to})
          }

        }
      </script>
    </Layouts.docs>
    """
  end
end
