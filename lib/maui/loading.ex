defmodule Maui.Loading do
  use Phoenix.Component

  @doc """
  Renders a loading bar component, replace topbar.js.

  put this in your layout or in `root.html.heex`

    <Maui.Loading.loading_bar />

  to override color:
    <Maui.Loading.loading_bar data-delay="1" class="!bg-amber-400 !shadow-amber-500/20" />


  """
  attr :delay, :integer, default: 500
  attr :class, :string, default: ""

  def loading_bar(assigns) do
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
