defmodule Maui.Container do
  @moduledoc """
  Container components for organizing content with consistent styling.

  ## Card

  Basic card container:

      <.card>
        Card content goes here
      </.card>

  ## Card with Header

      <.card>
        <.card_header>
          <.card_title>Card Title</.card_title>
          <.card_description>Card description</.card_description>
        </.card_header>
      </.card>

  ## Full Card Example

      <.card>
        <.card_header>
          <.card_title>Profile</.card_title>
          <.card_description>Manage your account settings</.card_description>
          <.card_action>
            <.button size="sm">Edit</.button>
          </.card_action>
        </.card_header>

        <.card_content>
          <p>Your profile information goes here.</p>
        </.card_content>

        <.card_footer>
          <.button variant="outline">Cancel</.button>
          <.button>Save Changes</.button>
        </.card_footer>
      </.card>

  ## Custom Styling

      <.card class="bg-blue-50 border-blue-200">
        Card with custom colors
      </.card>

  ## Icon

  Render Heroicons:

      <.icon name="hero-check-circle" />
      <.icon name="hero-x-mark" class="w-5 h-5" />

  ## Components

  | Component | Description |
  |-----------|-------------|
  | `card/1` | Main card container |
  | `card_header/1` | Card header section |
  | `card_title/1` | Card title text |
  | `card_description/1` | Card subtitle/description |
  | `card_action/1` | Action buttons in header (right-aligned) |
  | `card_content/1` | Main content area |
  | `card_footer/1` | Footer section |
  | `header/1` | Page header component |
  | `icon/1` | Heroicon component |
  """

  use Phoenix.Component

  attr :class, :string, default: ""
  attr :rest, :global

  slot :inner_block

  def card(assigns) do
    ~H"""
    <div
      class={[
        "bg-card text-card-foreground flex flex-col gap-6 rounded-xl border py-6 shadow-sm",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  slot :inner_block

  def card_header(assigns) do
    ~H"""
    <div class="@container/card-header grid auto-rows-min grid-rows-[auto_auto] items-start gap-2 px-6 has-data-[slot=card-action]:grid-cols-[1fr_auto] [.border-b]:pb-6">
      {render_slot(@inner_block)}
    </div>
    """
  end

  slot :inner_block

  def card_title(assigns) do
    ~H"""
    <div class="leading-none font-semibold">
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a header with title.
  """
  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between gap-6", "pb-4"]}>
      <div>
        <h1 class="text-lg font-semibold leading-8">
          {render_slot(@inner_block)}
        </h1>
        <p :if={@subtitle != []} class="text-sm text-base-content/70">
          {render_slot(@subtitle)}
        </p>
      </div>
      <div class="flex-none">{render_slot(@actions)}</div>
    </header>
    """
  end

  slot :inner_block

  def card_description(assigns) do
    ~H"""
    <div class="text-muted-foreground text-sm">
      {render_slot(@inner_block)}
    </div>
    """
  end

  slot :inner_block

  def card_action(assigns) do
    ~H"""
    <div class="col-start-2 row-span-2 row-start-1 self-start justify-self-end">
      {render_slot(@inner_block)}
    </div>
    """
  end

  slot :inner_block

  def card_content(assigns) do
    ~H"""
    <div class="px-6">
      {render_slot(@inner_block)}
    </div>
    """
  end

  slot :inner_block

  def card_footer(assigns) do
    ~H"""
    <div class="flex items-center px-6 [.border-t]:pt-6">
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  ported from core components
  Renders a [Heroicon](https://heroicons.com).

  Heroicons come in three styles – outline, solid, and mini.
  By default, the outline style is used, but solid and mini may
  be applied by using the `-solid` and `-mini` suffix.

  You can customize the size and colors of the icons by setting
  width, height, and background color classes.

  Icons are extracted from the `deps/heroicons` directory and bundled within
  your compiled app.css by the plugin in `assets/vendor/heroicons.js`.

  ## Examples

      <.icon name="hero-x-mark" />
      <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
  """
  attr :name, :string, required: true
  attr :class, :string, default: "size-4"

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end
end
