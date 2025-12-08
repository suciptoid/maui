defmodule Maui.Flash do
  use Phoenix.LiveComponent

  defmodule Message do
    defstruct id: nil,
              icon: nil,
              message: nil,
              type: :info,
              duration: 5,
              auto_dismiss: true,
              dismissable: true,
              class: "",
              show_close: true

    def new(message \\ "") do
      %__MODULE__{
        id: "fl#{System.unique_integer()}",
        message: message
      }
    end
  end

  @default_container_id "flash-container"
  @default_position "top-center"
  @default_limit 5

  def mount(socket) do
    socket = socket |> stream(:flashs, [])
    {:ok, socket}
  end

  def update(%{from: :send_flash, flash: flash}, socket) do
    socket = stream_insert(socket, :flashs, flash, limit: socket.assigns.limit, at: 0)

    {:ok, socket}
  end

  def update(%{from: :update_flash, flash: flash}, socket) do
    socket =
      stream_insert(socket, :flashs, flash, limit: socket.assigns.limit, at: 0, update_only: true)

    {:ok, socket}
  end

  def update(assigns, socket) do
    flash = map_flash(assigns.flash)

    limit = Map.get(assigns, :limit, @default_limit)
    position = Map.get(assigns, :position, @default_position)

    socket =
      socket
      |> assign(position: position, limit: limit, id: assigns.id)
      |> then(fn socket ->
        if flash != [] do
          Enum.reduce(flash, socket, fn item, sock ->
            stream_insert(sock, :flashs, item, limit: limit, at: 0)
          end)
        else
          socket
        end
      end)

    {:ok, socket}
  end

  def handle_event("dismiss_flash", %{"id" => id}, socket) do
    {:noreply, stream_delete_by_dom_id(socket, :flashs, id)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.container
        id="flashs-stream"
        position={@position}
        phx-update="stream"
      >
        <.flash
          :for={{id, flash} <- @streams.flashs}
          id={id}
          data-flash-id={flash.id}
          data-duration={flash.duration}
          position={@position}
          class={flash.class}
          show_close={flash.show_close}
        >
          {flash.message}
        </.flash>
      </.container>
    </div>
    """
  end

  @doc """
  Use .flash_group to place flash container in your layout.

  If you want to use in liveview page, pass option `live={true}`

  example:
  ```elixir
  <Maui.Flash.flash_group flash={@flash} live={true}>
  ```

  """
  attr :flash, :map, required: true
  attr :live, :boolean, default: false
  attr :limit, :integer, default: 5

  attr :position, :string,
    default: @default_position,
    values: [
      "top-left",
      "top-right",
      "top-center",
      "bottom-left",
      "bottom-right",
      "bottom-center"
    ]

  attr :auto_dismiss, :integer, default: 5000
  attr :show_close, :boolean, default: true

  def flash_group(assigns) do
    assigns =
      assign_new(assigns, :id, fn ->
        @default_container_id
      end)

    if assigns[:live] do
      ~H"""
      <.live_component
        id={@id}
        module={Maui.Flash}
        limit={@limit}
        flash={@flash}
        position={@position}
      />
      """
    else
      flash = map_flash(assigns[:flash])
      assigns = assign(assigns, :flashs, flash)

      ~H"""
      <.container id={@id} position={@position}>
        <Maui.Flash.flash
          :for={flash <- @flashs}
          id={flash.id}
          data-flash-id={flash.id}
          position={@position}
        >
          {flash.message}
        </Maui.Flash.flash>
      </.container>
      """
    end
  end

  @doc """
  Individual flash message component.
  """
  attr :id, :string
  attr :position, :string, default: @default_position
  attr :class, :string, default: ""
  attr :show_close, :boolean, default: true
  attr :rest, :global
  slot :inner_block

  def flash(assigns) do
    ~H"""
    <div
      id={@id}
      role="alert"
      aria-hidden="true"
      data-position={@position}
      class={[
        "bg-background text-secondary-foreground text-sm group",
        "w-full rounded-md border border-border py-3 px-4 shadow-sm",
        "transition-all duration-400 opacity-0",
        "absolute left-0 right-0 data-[position^='top-']:top-0 data-[position^='bottom-']:bottom-0",
        "m-auto z-[calc(1000-var(--flash-index))] not-aria-hidden:translate-y-[calc(var(--flash-offset-y))] not-aria-hidden:opacity-100",
        @class
      ]}
      {@rest}
    >
      <div class="flash-content overflow-hidden relative">
        {render_slot(@inner_block)}
      </div>

      <button
        :if={@show_close}
        data-close
        class="absolute hidden group-hover:flex top-1.5 right-1.5 p-0.5 w-fit items-center justify-center rounded-sm hover:bg-popover/90"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="size-4"
        >
          <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
        </svg>
      </button>
    </div>
    """
  end

  @doc """
  Flash container with positioning support.
  """
  slot :inner_block
  attr :position, :string, default: @default_position
  attr :rest, :global

  def container(assigns) do
    position_classes =
      case assigns.position do
        "top-right" -> "top-[1rem] right-[1rem] "
        "top-center" -> "top-[1rem] left-1/2 -translate-x-1/2 "
        "top-left" -> "top-[1rem] left-[1rem] "
        "bottom-right" -> "bottom-[1rem] right-[1rem] "
        "bottom-center" -> "bottom-[1rem] left-1/2 -translate-x-1/2 "
        "bottom-left" -> "bottom-[1rem] left-[1rem]"
        _ -> "bottom-[1rem] right-[1rem]"
      end

    assigns = assign(assigns, :position_classes, position_classes)

    ~H"""
    <div
      data-position={@position}
      phx-hook="Maui.FlashGroup"
      class={[
        "fixed z-10  flex flex-col w-[300px]",
        @position_classes
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp map_flash(flash) do
    Enum.map(flash, fn {key, value} -> %{key: key, value: value} end)
    |> Enum.filter(fn f ->
      key =
        case f.key do
          k when is_atom(k) -> Atom.to_string(k)
          k when is_binary(k) -> k
          _ -> ""
        end

      String.starts_with?(key, ["error", "info", "flash", "toast", "success", "warning"])
    end)
    |> Enum.map(fn f ->
      id =
        "fl#{System.unique_integer([:positive])}"

      case f.value do
        v when is_binary(v) -> %Message{id: id, message: v}
        {type, message} -> %Message{id: id, type: type, message: message}
        _ -> %Message{id: id, message: f.value}
      end
    end)
  end

  def send_flash(%Message{} = flash) do
    flash =
      Map.update(flash, :id, "fl-#{System.unique_integer([:positive])}", fn v ->
        if is_nil(v), do: "fl-#{System.unique_integer([:positive])}", else: v
      end)

    Phoenix.LiveView.send_update(Maui.Flash,
      id: @default_container_id,
      flash: flash,
      from: :send_flash
    )

    {:ok, flash}
  end

  def send_flash(message) do
    send_flash(%Message{id: "fl-#{System.unique_integer([:positive])}", message: message})
  end

  def update_flash(%Message{} = flash) do
    Phoenix.LiveView.send_update(Maui.Flash,
      id: @default_container_id,
      flash: flash,
      from: :update_flash
    )

    {:ok, flash}
  end
end
