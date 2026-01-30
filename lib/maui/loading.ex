defmodule Maui.Loading do
  @moduledoc """
  Loading indicators and progress components.

  ## Topbar Loading Indicator

  A progress bar that shows during page transitions and form submissions,
  replacing the traditional topbar.js library.

  Add to your root layout:

      <Maui.Loading.topbar />

  ## Customization

  Adjust the delay and color:

      <Maui.Loading.topbar delay={100} class="!bg-amber-400 !shadow-amber-500/20" />

  ## How It Works

  The loading bar automatically appears when:
  - LiveView is navigating between pages
  - Forms are being submitted
  - `phx-click` events are processing

  It automatically hides when the operation completes.

  ## Attributes

  | Attribute | Type | Default | Description |
  |-----------|------|---------|-------------|
  | `delay` | `integer` | `300` | Milliseconds before showing the bar |
  | `class` | `string` | `""` | Additional CSS classes for the bar |
  """

  use Phoenix.Component

  @doc """
  Renders a loading bar component.

  ## Example

      <Maui.Loading.topbar />
      <Maui.Loading.topbar delay={100} class="!bg-amber-400" />
  """
  attr :delay, :integer, default: 300
  attr :class, :string, default: ""

  def topbar(assigns) do
    ~H"""
    <div
      phx-hook="Maui.LoadingBar"
      data-delay={@delay}
      id="loadingbar"
      class="w-full z-[1000] fixed top-0 left-0 right-0 pointer-events-none"
    >
      <div
        id="loadingbar-progress"
        class={[
          "h-0.5 bg-blue-600/90 shadow-xs shadow-blue-600/40 rounded-e-md transition-all duration-300 ease-out",
          @class
        ]}
        style="width: 0%;"
      >
      </div>
    </div>
    """
  end
end
