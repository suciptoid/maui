defmodule AppWeb.Live.DemoProgressBadges do
  use AppWeb, :live_view
  use Maui

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:current_value, 35)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("update_progress", %{"value" => value}, socket) do
    new_value = String.to_integer(value)
    {:noreply, socket |> assign(:current_value, new_value)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.docs flash={@flash} live_action={:progress_badges}>
      <div class="space-y-8">
        <div>
          <h2 class="text-2xl font-bold">Progress Bars</h2>
          <p class="text-muted-foreground mt-2">
            Visual indicators of progress for tasks and loading states.
          </p>
        </div>

        <div class="space-y-6">
          <div class="grid grid-cols-1 md:grid-cols-1 gap-6">
            <div class="bg-card p-6 rounded-lg border border-border">
              <h3 class="text-lg font-semibold mb-4">Basic Progress Bar</h3>
              <Maui.Components.progress value={@current_value} min={0.0} max={100.0} />
              <div class="mt-4 flex items-center gap-4">
                <span class="text-sm">Value: {@current_value}%</span>
                <input
                  type="range"
                  min="0"
                  max="100"
                  value={@current_value}
                  phx-change="update_progress"
                  class="flex-1"
                />
              </div>
            </div>

            <div class="bg-card p-6 rounded-lg border border-border">
              <h3 class="text-lg font-semibold mb-4">Custom Min/Max Progress</h3>
              <Maui.Components.progress value={75.0} min={50.0} max={200.0} class="h-3" />
              <p class="mt-2 text-sm text-muted-foreground">Value: 75, Range: 50-200</p>
            </div>
          </div>
        </div>

        <div class="pt-8">
          <h2 class="text-2xl font-bold">Badges</h2>
          <p class="text-muted-foreground mt-2">
            Small status descriptors for content or UI elements.
          </p>
        </div>

        <div class="space-y-6">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div class="bg-card p-6 rounded-lg border border-border">
              <h3 class="text-lg font-semibold mb-4">Badge Variants</h3>
              <div class="flex flex-wrap gap-3">
                <Maui.Components.badge variant="default">
                  Default
                </Maui.Components.badge>
                <Maui.Components.badge variant="secondary">
                  Secondary
                </Maui.Components.badge>
                <Maui.Components.badge variant="destructive">
                  Destructive
                </Maui.Components.badge>
                <Maui.Components.badge variant="outline">
                  Outline
                </Maui.Components.badge>
              </div>
            </div>

            <div class="bg-card p-6 rounded-lg border border-border">
              <h3 class="text-lg font-semibold mb-4">Badge with Custom Styling</h3>
              <div class="flex flex-wrap gap-3">
                <Maui.Components.badge class="bg-blue-500 hover:bg-blue-600 text-white">
                  Custom Blue
                </Maui.Components.badge>
                <Maui.Components.badge class="bg-green-500 hover:bg-green-600 text-white">
                  Custom Green
                </Maui.Components.badge>
                <Maui.Components.badge class="bg-purple-500 hover:bg-purple-600 text-white">
                  Custom Purple
                </Maui.Components.badge>
              </div>
            </div>
          </div>

          <div class="bg-card p-6 rounded-lg border border-border">
            <h3 class="text-lg font-semibold mb-4">Badge in Context</h3>
            <div class="flex flex-wrap gap-3 items-center">
              <span>Profile Status:</span>
              <Maui.Components.badge variant="secondary">Active</Maui.Components.badge>
              <span>Notification:</span>
              <Maui.Components.badge variant="destructive">Urgent</Maui.Components.badge>
              <span>User Type:</span>
              <Maui.Components.badge variant="outline">Admin</Maui.Components.badge>
            </div>
          </div>
        </div>

        <div class="pt-8">
          <h2 class="text-lg font-semibold mb-4">Usage Examples</h2>
          <div class="bg-accent/30 rounded-lg border border-border p-6">
            <h3 class="text-sm font-semibold mb-2">Progress Bar</h3>
            <pre class="bg-background p-4 rounded text-sm overflow-x-auto"><code><%= ~s|<Maui.Components.progress value={65} min={0} max={100} class="h-2" />| %></code></pre>

            <h3 class="text-sm font-semibold mb-2 mt-4">Badge</h3>
            <pre class="bg-background p-4 rounded text-sm overflow-x-auto"><code><%= ~s|<Maui.Components.badge variant="default">Default</Maui.Components.badge>| %></code></pre>
          </div>
        </div>
      </div>
    </Layouts.docs>
    """
  end
end
