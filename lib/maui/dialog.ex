defmodule Maui.Dialog do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  attr :class, :string, default: ""
  attr :rest, :global
  slot :inner_block

  def backdrop(assigns) do
    ~H"""
    <div
      class={[
        "not-[hidden]:animate-in [hidden]:animate-out [hidden]:fade-out-0 not-[hidden]:fade-in-0 fixed inset-0 z-50 bg-black/50",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :id, :string, required: true
  attr :class, :string, default: ""
  attr :rest, :global
  slot :inner_block

  def content(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "not-[hidden]:animate-in [hidden]:animate-out [hidden]:fade-out-0 not-[hidden]:fade-in-0 [hidden]:zoom-out-95 not-[hidden]:zoom-in-95",
        "bg-background fixed top-[50%] left-[50%] z-50 grid w-full max-w-[calc(100%-2rem)] translate-x-[-50%] translate-y-[-50%] gap-4 rounded-lg border p-6 shadow-lg duration-200 sm:max-w-lg",
        @class
      ]}
      {@rest}
    >
      <.focus_wrap id={"#{@id}-focus"}>
        {render_slot(@inner_block)}
      </.focus_wrap>
    </div>
    """
  end

  attr :id, :string, required: true
  attr :on_cancel, JS, default: %JS{}
  attr :alert, :boolean, default: false
  attr :size, :string, values: ["sm", "md", "lg", "xl"], default: "md"

  slot :inner_block
  slot :trigger, required: false
  slot :content, required: false, doc: "To override the content container"

  def dialog(assigns) do
    size_class =
      case assigns[:size] do
        "sm" -> "sm:max-w-sm"
        "md" -> "md:max-w-md"
        "lg" -> "lg:max-w-lg"
        "xl" -> "xl:max-w-xl"
      end

    assigns = assign(assigns, size_class: size_class)

    ~H"""
    <div
      id={@id}
      phx-window-keydown={JS.exec("data-cancel")}
      phx-key="escape"
      phx-remove={hide_dialog(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
    >
      {render_slot(@trigger, %{
        "phx-click": show_dialog(@id)
      })}
      <.backdrop
        id={"#{@id}-backdrop"}
        hidden
        phx-click={if @alert, do: nil, else: JS.exec("data-cancel", to: "##{@id}")}
      />

      <%= if @content != [] do %>
        {render_slot(
          @content,
          {%{id: "#{@id}-content", hidden: true},
           %{hide: JS.exec("data-cancel", to: "##{@id}"), show: show_dialog(@id)}}
        )}
      <% end %>

      <.content
        :if={@content == []}
        role={if @alert, do: "alertdialog", else: "dialog"}
        aria-modal="true"
        class={@size_class}
        id={"#{@id}-content"}
        hidden
      >
        {render_slot(@inner_block, %{
          hide: JS.exec("data-cancel", to: "##{@id}"),
          show: show_dialog(@id)
        })}
      </.content>
    </div>
    """
  end

  def hide_dialog(id) do
    JS.set_attribute({"hidden", true}, to: "##{id}-backdrop")
    |> JS.set_attribute({"hidden", true}, to: "##{id}-content")
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end

  def show_dialog(id) do
    JS.push_focus()
    |> JS.remove_attribute("hidden", to: "##{id}-backdrop")
    |> JS.remove_attribute("hidden", to: "##{id}-content")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end
end
