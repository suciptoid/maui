defmodule Maui.Alert do
  use Phoenix.Component

  attr :class, :string, default: ""
  attr :variant, :string, values: ["default", "destructive"], default: "default"

  slot :icon, required: false
  slot :title, required: false
  slot :description, required: false
  slot :inner_block

  def alert(assigns) do
    variant_class =
      case assigns[:variant] do
        "default" ->
          "bg-card text-card-foreground"

        "destructive" ->
          "text-destructive bg-card [&>svg]:text-current *:data-[alert-desc]:text-destructive/90"
      end

    assigns = assign(assigns, variant_class: variant_class)

    ~H"""
    <div class={[
        "relative w-full rounded-lg border border-border px-4 py-3 text-sm grid grid-cols-[0_1fr] gap-y-0.5 items-start ",
        "has-[>[data-icon]]:grid-cols-[calc(var(--spacing)*4)_1fr] has-[>[data-icon]]:gap-x-3 [&>[data-icon]]:size-4 [&>[data-icon]]:text-current",
        @variant_class,
      @class
    ]}>
      <div :if={@icon !== []} data-icon="alert-icon">
      {render_slot(@icon)}
      </div>
      <.alert_title :if={@title !== []}>
        {render_slot(@title)}
      </.alert_title>
      <.alert_description :if={@description !== []}>
        {render_slot(@description)}
      </.alert_description>
      { render_slot(@inner_block) }
    </div>
    """
  end

  @doc """
  Renders the title of an alert.
  """
  attr :class, :string, default: ""
  slot :inner_block

  def alert_title(assigns) do
    ~H"""
    <div class={["col-start-2 line-clamp-1 min-h-4 font-medium tracking-tight", @class]}>
      { render_slot(@inner_block) }
    </div>
    """
  end

  @doc """
  Renders the description of an alert.
  """
  attr :class, :string, default: ""
  slot :inner_block

  def alert_description(assigns) do
    ~H"""
    <div data-alert-desc class={["text-muted-foreground col-start-2 grid justify-items-start gap-1 text-sm [&_p]:leading-relaxed", @class]}>
      { render_slot(@inner_block) }
    </div>
    """
  end
end
