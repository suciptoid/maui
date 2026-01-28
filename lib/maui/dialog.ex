defmodule Maui.Dialog do
  @moduledoc """
  A modal dialog component for LiveView applications.

  ## Basic Usage

  The simplest way to use a dialog is with a trigger button:

      <.dialog id="my-dialog">
        <:trigger :let={attr}>
          <.button {attr}>Open Dialog</.button>
        </:trigger>
        <p>Dialog content goes here.</p>
      </.dialog>

  ## Accessing Hide/Show Actions

  Use `:let` to access the `hide` and `show` JS commands:

      <.dialog :let={%{hide: hide, show: show}} id="my-dialog">
        <:trigger :let={attr}>
          <.button {attr}>Open</.button>
        </:trigger>
        <p>Content</p>
        <.button phx-click={hide}>Close</.button>
      </.dialog>

  ## Server-Controlled Dialog

  Control dialog visibility from your LiveView using the `show` attribute:

      # In your LiveView
      def mount(_params, _session, socket) do
        {:ok, assign(socket, show_dialog: false)}
      end

      def handle_event("open", _, socket), do: {:noreply, assign(socket, show_dialog: true)}
      def handle_event("close", _, socket), do: {:noreply, assign(socket, show_dialog: false)}

      # In template - use on_cancel to sync state when dismissed via backdrop/escape
      <.button phx-click="open">Open</.button>
      <.dialog id="my-dialog" show={@show_dialog} on_cancel={JS.push("close")}>
        <p>Server-controlled content</p>
        <.button phx-click="close">Close</.button>
      </.dialog>

  ### show={} vs :if={}

  Two approaches for server-controlled dialogs:

  | Approach | Behavior |
  |----------|----------|
  | `show={@visible}` | Dialog stays in DOM, visibility toggled. Form state preserved, animations work. |
  | `:if={@visible}` | Dialog mounted/unmounted. Form state resets, no exit animations. |

  **Using `show={}`** (recommended for most cases):

      <.dialog id="dialog" show={@show_dialog} on_cancel={JS.push("close")}>
        ...
      </.dialog>

  **Using `:if={}`** (when you want fresh state each time):

      <.dialog :if={@show_dialog} id="dialog" show={true} on_cancel={JS.push("close")}>
        ...
      </.dialog>

  ## Alert Dialog

  Use `alert={true}` to prevent closing via backdrop click (escape still works):

      <.dialog id="confirm-delete" alert={true}>
        <:trigger :let={attr}>
          <.button variant="destructive" {attr}>Delete</.button>
        </:trigger>
        <p>Are you sure? This cannot be undone.</p>
      </.dialog>

  ## Dialog Sizes

  Control max-width with the `size` attribute:

      <.dialog id="small" size="sm">...</.dialog>   # sm:max-w-sm
      <.dialog id="medium" size="md">...</.dialog>  # md:max-w-md (default)
      <.dialog id="large" size="lg">...</.dialog>   # lg:max-w-lg
      <.dialog id="xlarge" size="xl">...</.dialog>  # xl:max-w-xl

  ## Custom Content Slot

  Override the default content container for full customization:

      <.dialog id="custom">
        <:trigger :let={attr}>
          <.button {attr}>Open</.button>
        </:trigger>
        <:content :let={{attrs, %{hide: hide}}}>
          <div class="my-custom-dialog-class" {attrs}>
            <p>Fully customized container</p>
            <.button phx-click={hide}>Close</.button>
          </div>
        </:content>
      </.dialog>

  ## Programmatic Show/Hide

  Use `show_dialog/1` and `hide_dialog/1` functions directly:

      <.button phx-click={Maui.Dialog.show_dialog("my-dialog")}>Open</.button>
      <.button phx-click={Maui.Dialog.hide_dialog("my-dialog")}>Close</.button>

  ## Attributes

  | Attribute | Type | Default | Description |
  |-----------|------|---------|-------------|
  | `id` | `string` | required | Unique identifier for the dialog |
  | `show` | `boolean` | `false` | Control visibility from server |
  | `alert` | `boolean` | `false` | Prevent backdrop click dismiss |
  | `size` | `string` | `"md"` | Max width: "sm", "md", "lg", "xl" |
  | `on_cancel` | `JS` | `%JS{}` | JS command to run on cancel |

  ## Slots

  | Slot | Description |
  |------|-------------|
  | `inner_block` | Main dialog content |
  | `trigger` | Button/element to open dialog (receives `phx-click` attr) |
  | `content` | Override content container (receives attrs and hide/show) |
  """

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
  attr :show, :boolean, default: false, doc: "Control dialog visibility from server"
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

    cancel_action =
      if assigns[:show] do
        assigns[:on_cancel]
      else
        JS.exec(assigns[:on_cancel], "phx-remove")
      end

    assigns =
      assigns
      |> assign(:size_class, size_class)
      |> assign(:cancel_action, cancel_action)

    ~H"""
    <div
      id={@id}
      phx-window-keydown={JS.exec("data-cancel")}
      phx-key="escape"
      phx-remove={hide_dialog(@id)}
      data-cancel={@cancel_action}
    >
      {render_slot(@trigger, %{
        "phx-click": show_dialog(@id)
      })}
      <.backdrop
        id={"#{@id}-backdrop"}
        hidden={not @show}
        phx-click={if @alert, do: nil, else: JS.exec("data-cancel", to: "##{@id}")}
      />

      <%= if @content != [] do %>
        {render_slot(
          @content,
          {%{id: "#{@id}-content", hidden: not @show},
           %{hide: JS.exec("data-cancel", to: "##{@id}"), show: show_dialog(@id)}}
        )}
      <% end %>

      <.content
        :if={@content == []}
        role={if @alert, do: "alertdialog", else: "dialog"}
        aria-modal="true"
        class={@size_class}
        id={"#{@id}-content"}
        hidden={not @show}
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
