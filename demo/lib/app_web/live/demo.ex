defmodule AppWeb.Live.Demo do
  use AppWeb, :live_view
  use Maui

  def mount(_params, _session, socket) do
    form = to_form(%{"name" => "John Doe", "email" => "john@example.com", "text" => "text demo"})
    {:ok, socket |> assign(form: form) |> assign(:flash_placement, "top-center")}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("btn_click", params, socket) do
    dbg({"btn click", params})
    {:noreply, socket}
  end

  def handle_event("send_flash", _params, socket) do
    Maui.Flash.send_flash("Hi, I'm a flash message from #{socket.id}")
    assigns = %{}

    Maui.Flash.send_flash(~H"""
    <div class="flex flex-col">
      <span>Hello world</span>
      <.button size="sm">click me</.button>
    </div>
    """)

    {:noreply, socket}
  end

  def handle_event("custom_flash", _params, socket) do
    assigns = %{}

    message = ~H"""
    <div class="flex items-center gap-2">
      <div>
        <.icon name="hero-check-circle" class="size-6" /> Flash customized successfully!
      </div>
      <button
        data-close
        class=" hidden group-hover:flex top-1.5 right-1.5 p-0.5 w-fit items-center justify-center rounded-sm hover:bg-popover/90"
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

    Maui.Flash.send_flash(%Maui.Flash.Message{
      type: :info,
      message: message,
      duration: 8,
      show_close: false,
      class: "w-fit! border-green-500! bg-green-100! text-green-800!"
    })
    |> dbg

    {:noreply, socket}
  end

  def handle_event("update_flash", _prams, socket) do
    assigns = %{}

    message = ~H"""
    <div class="flex items-center gap-2">
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="24"
        height="24"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
        class="animate-spin text-blue-500"
      >
        <path stroke="none" d="M0 0h24v24H0z" fill="none" /><path d="M12 6l0 -3" /><path d="M16.25 7.75l2.15 -2.15" /><path d="M18 12l3 0" /><path d="M16.25 16.25l2.15 2.15" /><path d="M12 18l0 3" /><path d="M7.75 16.25l-2.15 2.15" /><path d="M6 12l-3 0" /><path d="M7.75 7.75l-2.15 -2.15" />
      </svg>
      Updating...
    </div>
    """

    Maui.Flash.send_flash(%Maui.Flash.Message{
      id: "update-me",
      type: :info,
      message: message,
      duration: -1
    })

    Process.send_after(self(), :update_flash, 10000)
    {:noreply, socket}
  end

  def handle_event("set_flash_placement", %{"placement" => placement}, socket) do
    {:noreply, socket |> assign(:flash_placement, placement)}
  end

  def handle_event("put_flash", _params, socket) do
    flash_id = "#{System.unique_integer([:positive])}"

    message =
      [
        "Short message.",
        "A bit longer message that spans two lines.",
        "This is a longer description that intentionally takes more vertical space to demonstrate stacking with varying heights.",
        "An even longer description that should span multiple lines so we can verify the clamped collapsed height and smooth expansion animation when hovering or focusing the viewport."
      ]
      |> Enum.random()

    {:noreply,
     socket
     |> put_flash(
       "info-#{flash_id}",
       {:info, message}
     )
     |> push_patch(to: "/flash")}
  end

  def handle_event("put_basic_flash", _params, socket) do
    {:noreply,
     socket
     |> put_flash(
       :info,
       "Flash message  dengan type :info"
     )
     |> push_patch(to: "/flash")}
  end

  def handle_event("put_redirect_flash", _params, socket) do
    {:noreply,
     socket
     |> put_flash(
       :info,
       "Flash message dari liveview ke deadview dengan type :info"
     )
     |> put_flash(
       :error,
       "Flash message dari liveview ke deadview dengan type :error"
     )
     |> push_navigate(to: "/lc")}
  end

  def handle_event("validate", params, socket) do
    socket = socket |> assign(:form, to_form(params))
    {:noreply, socket}
  end

  def handle_info(:update_flash, socket) do
    assigns = %{}

    message = ~H"""
    <div class="flex items-start gap-2">
      <.icon name="hero-check-circle" class="size-5" /> Flash updated from backend
    </div>
    """

    Maui.Flash.send_flash(%Maui.Flash.Message{
      id: "update-me",
      type: :info,
      duration: 5,
      message: message
    })

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.docs flash={@flash} live_action={@live_action}>
      <Maui.Flash.flash_group
        flash={@flash}
        position={@flash_placement}
        live={true}
      />
      <.demo_overview :if={@live_action == :index} />
      <.demo_inputs :if={@live_action == :inputs} form={@form} />
      <.demo_buttons :if={@live_action == :buttons} />
      <.demo_dropdown :if={@live_action == :dropdown} />
      <.demo_popover :if={@live_action == :popover} />
      <.demo_toast :if={@live_action == :toast} />
      <.demo_alert :if={@live_action == :alert} />
    </Layouts.docs>
    """
  end

  def demo_alert(assigns) do
    ~H"""
    <div class="space-y-6">
      <Maui.Alert.alert>
        <:icon>
          <%!-- <.icon name="hero-check-circle" class="size-5" /> --%>
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke-width="1.5"
            stroke="currentColor"
            class="size-5"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126ZM12 15.75h.007v.008H12v-.008Z"
            />
          </svg>
        </:icon>

        <:title>
          Hello Alert Title ahah tanpa desc
        </:title>

        <%!-- <:description>
          Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed non risus.
        </:description> --%>
      </Maui.Alert.alert>
      <Maui.Alert.alert>
        <:icon>
          <.icon name="hero-check-circle" class="size-5" />
        </:icon>

        <:title>
          Hello Alert Title ahah
        </:title>

        <:description>
          Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed non risus.
        </:description>
      </Maui.Alert.alert>
      <Maui.Alert.alert variant="destructive">
        <:icon>
          <.icon name="hero-exclamation-triangle" class="size-5" />
        </:icon>

        <:title>
          Hello Alert Title ahah
        </:title>

        <:description>
          Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed non risus.
        </:description>
      </Maui.Alert.alert>
    </div>
    """
  end

  defp demo_overview(assigns) do
    ~H"""
    <div class="space-y-6">
      <div>
        <h2 class="text-3xl font-bold">Welcome to Maui Components</h2>
        <p class="text-muted-foreground mt-2">
          A comprehensive collection of Phoenix LiveView components built with Tailwind CSS.
        </p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mt-8">
        <.component_card
          title="Inputs"
          description="Text inputs, checkboxes, radio buttons, switches, and more."
          icon="hero-cursor-arrow-rays"
          patch={~p"/inputs"}
        />
        <.component_card
          title="Buttons"
          description="Various button styles, sizes, and variants for your application."
          icon="hero-cursor-arrow-ripple"
          patch={~p"/buttons"}
        />
        <.component_card
          title="Dropdown"
          description="Dropdown menus with items, separators, and shortcuts."
          icon="hero-chevron-down"
          patch={~p"/dropdown"}
        />
        <.component_card
          title="Popover"
          description="Floating UI popovers for contextual information."
          icon="hero-chat-bubble-left"
          patch={~p"/popover"}
        />
        <.component_card
          title="Toast"
          description="Toast notifications with beautiful animations."
          icon="hero-bell"
          patch={~p"/toast"}
        />
        <.component_card
          title="Toast"
          description="Toast notifications with beautiful animations."
          icon="hero-exclamation-triangle"
          patch={~p"/alert"}
        />
        <.component_card
          title="Progress & Badges"
          description="Progress bars and badge components for status indicators."
          icon="hero-bolt"
          patch={~p"/progress_badges"}
        />
      </div>

      <div class="mt-8 p-6 bg-accent/30 rounded-lg border border-border">
        <h3 class="text-lg font-semibold mb-2">Getting Started</h3>
        <p class="text-muted-foreground">
          Use the sidebar navigation to explore different components. Each page includes
          interactive examples and usage patterns.
        </p>
      </div>
    </div>
    """
  end

  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :icon, :string, required: true
  attr :patch, :string, required: true

  defp component_card(assigns) do
    ~H"""
    <.link
      patch={@patch}
      class="block p-6 rounded-lg border border-border bg-card hover:bg-accent/50 transition-colors group"
    >
      <div class="flex items-start gap-4">
        <div class="p-2 rounded-md bg-primary/10 group-hover:bg-primary/20 transition-colors">
          <.icon name={@icon} class="size-6 text-primary" />
        </div>
        <div class="flex-1">
          <h3 class="font-semibold text-lg mb-1">{@title}</h3>
          <p class="text-sm text-muted-foreground">{@description}</p>
        </div>
      </div>
    </.link>
    """
  end

  defp demo_popover(assigns) do
    ~H"""
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
          <.button aria-haspopup="menu">
            Click Me
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
    """
  end

  defp demo_inputs(assigns) do
    ~H"""
    <div class="space-y-8">
      <div>
        <h2 class="text-lg font-semibold mb-4">Text Inputs</h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <.input id="input-text" type="text" placeholder="Enter text" label="Input Text" />
          <.input
            id="input-password"
            type="password"
            placeholder="Enter password"
            label="Input Password"
            data-bwignore
          />
          <.input id="input-file" type="file" placeholder="Enter password" label="Input File" />

          <.input
            id="input-disabled"
            type="text"
            disabled
            placeholder="Enter text"
            label="Input Disabled"
          />
          <div class="grid w-full max-w-sm items-center gap-3">
            <.label for="email">Field with custom label</.label>
            <.input type="email" id="email" placeholder="you@company.com" data-bwignore />
          </div>

          <div class="flex justify-end flex-col">
            <p class="text-xs text-gray-400 p-1">Without label</p>
            <.input type="text" placeholder="Enter text" id="custom-id" />
          </div>
          <div class="flex justify-end flex-col">
            <.form :let={f} id="form-demo" for={@form} phx-change="validate">
              <.input
                field={f[:name]}
                placeholder="Enter your name"
                label="With Phoenix Form"
              />

              <span class="text-gray-400 text-sm">
                Your Input: {f[:name].value}
              </span>
            </.form>
          </div>
          <div class="flex justify-end flex-col">
            <.textarea
              label="Textarea"
              placeholder="Enter text..."
              field={@form[:text]}
              id="custom-textarea"
            />
          </div>
        </div>
      </div>

      <div>
        <h2 class="text-lg font-semibold mb-4">Checkboxes</h2>
        <div class="space-y-4">
          <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
            <.checkbox :for={cb <- [1, 2, 3, 4]} id={"demo-checkbox-#{cb}"} label={"Checkbox #{cb}"} />
          </div>

          <.checkbox id="demo-checkbox-label" label="Agree to terms and conditions" />

          <div class="flex items-start gap-3">
            <.checkbox id="terms-2" checked />
            <div class="grid gap-2">
              <.label for="terms-2">Accept terms and conditions</.label>
              <p class="text-muted-foreground text-sm">
                By clicking this checkbox, you agree to the terms and conditions.
              </p>
            </div>
          </div>

          <div class="flex items-start gap-3">
            <.checkbox id="toggle" class="peer" disabled />
            <.label for="toggle">Enable notifications</.label>
          </div>

          <.label class="hover:bg-accent/50 flex items-start gap-3 rounded-lg border border-border p-3 has-checked:border-blue-600 has-checked:bg-blue-50 dark:has-checked:border-blue-900 dark:has-checked:bg-blue-950">
            <.checkbox
              id="toggle-2"
              class="checked:border-blue-600! checked:bg-blue-600! checked:text-white dark:checked:border-blue-700 dark:checked:bg-blue-700"
            />
            <div class="grid gap-1.5 font-normal">
              <p class="text-sm leading-none font-medium">
                Enable notifications
              </p>
              <p class="text-muted-foreground text-sm">
                You can enable or disable notifications at any time.
              </p>
            </div>
          </.label>
        </div>
      </div>

      <div>
        <h2 class="text-lg font-semibold mb-4">Radio Buttons</h2>
        <div role="radiogroup" class="grid gap-3">
          <div class="flex items-center gap-3">
            <.label class="flex items-center gap-2 text-sm leading-none font-medium select-none group-data-[disabled=true]:pointer-events-none group-data-[disabled=true]:opacity-50 peer-disabled:cursor-not-allowed peer-disabled:opacity-50">
              <.radio name="radio-1" value="compact" /> Compact
            </.label>
            <.label class="flex items-center gap-2 text-sm leading-none font-medium select-none group-data-[disabled=true]:pointer-events-none group-data-[disabled=true]:opacity-50 peer-disabled:cursor-not-allowed peer-disabled:opacity-50">
              <.radio name="radio-1" value="default" /> Default
            </.label>
          </div>
        </div>
      </div>

      <div>
        <h2 class="text-lg font-semibold mb-4">Switches</h2>
        <div class="flex flex-col gap-4">
          <.switch name="switch-1" id="switch-1" class="peer" />
          <.switch id="switch-2" label="Airplane Mode" />
        </div>
      </div>
    </div>
    """
  end

  defp demo_buttons(assigns) do
    ~H"""
    <div class="space-y-8">
      <div :for={size <- ["sm", "default", "lg"]}>
        <h2 class="text-lg font-semibold mb-4 capitalize">Size: {size}</h2>
        <div class="flex flex-wrap gap-3">
          <.button
            :for={variant <- ["default", "secondary", "destructive", "outline", "ghost", "link"]}
            variant={variant}
            size={size}
            phx-click="btn_click"
          >
            {String.capitalize(variant)}
          </.button>
        </div>
      </div>

      <div>
        <h2 class="text-lg font-semibold mb-4">Icon Buttons</h2>
        <div class="flex flex-wrap gap-3">
          <.button
            :for={variant <- ["default", "secondary", "destructive", "outline", "ghost"]}
            variant={variant}
            size="icon"
          >
            <.icon name="hero-heart" class="w-4 h-4" />
          </.button>
        </div>
      </div>

      <div>
        <h2 class="text-lg font-semibold mb-4">Buttons with Links</h2>
        <div class="flex flex-wrap gap-3">
          <.button variant="link" patch={~p"/link/patch"}>
            Button With Patch
          </.button>

          <.button variant="outline" navigate={~p"/link/navigate"}>
            Button With Navigate
          </.button>

          <.button variant="secondary" href={~p"/link/href"}>
            Button With Href
          </.button>

          <.button variant="secondary" href={~p"/link/href"}>
            <.icon name="hero-heart" class="w-4 h-4" /> Button With Icon
          </.button>
        </div>
      </div>
    </div>
    """
  end

  defp demo_dropdown(assigns) do
    ~H"""
    <div class="space-y-8">
      <div>
        <h2 class="text-lg font-semibold mb-4">Menu Button with Items</h2>
        <div class="flex flex-wrap gap-4">
          <Maui.Dropdown.menu_button content_class="w-52">
            <.icon name="hero-user" class="size-4" /> Update Profile
            <:item shortcut="⇧⌘P">
              <.icon name="hero-user" class="size-4" /> Profile
            </:item>
            <:item shortcut="⌘S">
              <.icon name="hero-cog" class="size-4" /> Settings
            </:item>
            <:item>
              Print Items
              <Maui.Dropdown.menu_shortcut>
                ⌘P
              </Maui.Dropdown.menu_shortcut>
            </:item>
            <:item shortcut="⇧⌘P" variant="destructive">
              <.icon name="hero-trash" class="size-4" /> Delete
            </:item>
          </Maui.Dropdown.menu_button>

          <Maui.Dropdown.menu_button content_class="w-52">
            <.icon name="hero-trash" class="size-4" /> Delete Options
            <:items>
              <Maui.Dropdown.menu_item variant="destructive">
                <.icon name="hero-trash" class="size-4" /> Delete User Profile
              </Maui.Dropdown.menu_item>
              <Maui.Dropdown.menu_item variant="destructive">
                <.icon name="hero-trash" class="size-4" /> Delete User Data
              </Maui.Dropdown.menu_item>
              <Maui.Dropdown.menu_separator />
              <Maui.Dropdown.menu_item variant="default" phx-click="undo">
                <.icon name="hero-arrow-left" class="size-4" /> Undo
              </Maui.Dropdown.menu_item>
            </:items>
          </Maui.Dropdown.menu_button>
        </div>
      </div>

      <div class="p-6 bg-accent/30 rounded-lg border border-border">
        <h3 class="text-sm font-semibold mb-2">Usage</h3>
        <p class="text-sm text-muted-foreground">
          Dropdown menus support keyboard shortcuts, separators, and different variants.
          Use the destructive variant for dangerous actions.
        </p>
      </div>
    </div>
    """
  end

  defp demo_toast(assigns) do
    ~H"""
    <div class="space-y-8">
      <div>
        <h2 class="text-lg font-semibold mb-4">Toast Notifications</h2>
        <p class="text-muted-foreground mb-4">
          Toast notifications appear temporarily to provide feedback to users.
        </p>
      </div>

      <div>
        <h3 class="text-md font-medium mb-3">Placement</h3>
      </div>
      <div class="w-1/2 grid grid-cols-3 gap-2">
        <.button phx-click="set_flash_placement" phx-value-placement="top-left" variant="secondary">
          <.icon name="hero-arrow-up-left" class="size-4" /> Top Left
        </.button>
        <.button phx-click="set_flash_placement" phx-value-placement="top-center" variant="secondary">
          <.icon name="hero-arrow-up" class="size-4" /> Top Center
        </.button>
        <.button phx-click="set_flash_placement" phx-value-placement="top-right" variant="secondary">
          <.icon name="hero-arrow-up-right" class="size-4" /> Top Right
        </.button>
      </div>
      <div class="w-1/2 grid grid-cols-3 gap-2">
        <.button phx-click="set_flash_placement" phx-value-placement="bottom-left" variant="secondary">
          <.icon name="hero-arrow-down-left" class="size-4" /> Bottom Left
        </.button>
        <.button
          phx-click="set_flash_placement"
          phx-value-placement="bottom-center"
          variant="secondary"
        >
          <.icon name="hero-arrow-down" class="size-4" /> Bottom Center
        </.button>
        <.button
          phx-click="set_flash_placement"
          phx-value-placement="bottom-right"
          variant="secondary"
        >
          <.icon name="hero-arrow-down-right" class="size-4" /> Bottom Right
        </.button>
      </div>

      <div>
        <h3 class="text-md font-medium mb-3">Preview</h3>
      </div>

      <.button phx-click="put_flash" variant="secondary">
        <.icon name="hero-bell" class="size-4" /> Test Flash Message
      </.button>

      <.button phx-click="put_basic_flash" variant="secondary">
        <.icon name="hero-bell" class="size-4" /> Test Basic Message
      </.button>
      <.button phx-click="put_redirect_flash" variant="destructive">
        <.icon name="hero-bell" class="size-4" /> To non liveview page
      </.button>

      <.button phx-click="send_flash" variant="default">
        <.icon name="hero-bell" class="size-4" /> Use send_flash
      </.button>

      <.button phx-click="update_flash" variant="default">
        <.icon name="hero-bell" class="size-4" /> Update Flash
      </.button>

      <.button phx-click="custom_flash" variant="outline">
        <.icon name="hero-bell" class="size-4" /> Customize Flash
      </.button>

      <div class="p-6 bg-accent/30 rounded-lg border border-border">
        <h3 class="text-sm font-semibold mb-2">Features</h3>
        <ul class="text-sm text-muted-foreground space-y-1 list-disc list-inside">
          <li>Stacked animations with peek effect</li>
          <li>Swipe to dismiss</li>
          <li>Auto-dismiss with configurable duration</li>
          <li>Accessible with ARIA attributes</li>
        </ul>
      </div>
    </div>
    """
  end
end
