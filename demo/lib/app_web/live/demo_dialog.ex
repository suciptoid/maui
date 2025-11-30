defmodule AppWeb.Live.DemoDialog do
  use AppWeb, :live_view
  use Maui

  def render(assigns) do
    ~H"""
    <Layouts.docs flash={@flash} live_action={@live_action}>
      <!-- Basic Dialog -->
      <div class="mb-12">
        <h2 class="text-xl font-semibold mb-4">Basic Dialog</h2>
        <p class="text-gray-600 mb-4">
          A simple dialog with form elements for collecting user input.
        </p>

        <div class="flex items-center gap-3 mb-4">
          <.dialog
            :let={%{hide: dialog_hide}}
            id="x"
            on_cancel={Phoenix.LiveView.JS.toggle_attribute({"data-canceled", "true", "false"})}
          >
            <:trigger :let={dialog_attr}>
              <.button variant="secondary" type="button" {dialog_attr}>
                Open Dialog
              </.button>
            </:trigger>
            <form class="space-y-4">
              <.input type="text" name="name" placeholder="Name" />
              <.input type="password" name="name" placeholder="Password" />
              <div class="flex gap-2 justify-end">
                <.button variant="secondary" type="button" phx-click={dialog_hide}>
                  Cancel
                </.button>
                <.button>
                  Change
                </.button>
              </div>
            </form>
          </.dialog>
        </div>

        <div class="bg-gray-50 p-4 rounded-lg">
          <pre class="text-sm"><code><%=
            "<.dialog :let={%{hide: hide}} id=\"x\">\n" <>
            "  <:trigger :let={attr}>\n" <>
            "    <.button variant=\"secondary\" type=\"button\" {attr}>\n" <>
            "      Open Dialog\n" <>
            "    </.button>\n" <>
            "  </:trigger>\n" <>
            "  <form class=\"space-y-4\">\n" <>
            "    <.input type=\"text\" name=\"name\" placeholder=\"Name\" />\n" <>
            "    <.input type=\"password\" name=\"name\" placeholder=\"Password\" />\n" <>
            "    <div class=\"flex gap-2 justify-end\">\n" <>
            "      <.button variant=\"secondary\" type=\"button\" phx-click={hide}>\n" <>
            "        Cancel\n" <>
            "      </.button>\n" <>
            "      <.button>\n" <>
            "        Change\n" <>
            "      </.button>\n" <>
            "    </div>\n" <>
            "  </form>\n" <>
            "</.dialog>"
          %></code></pre>
        </div>
      </div>
      
    <!-- Destructive Dialog -->
      <div class="mb-12">
        <h2 class="text-xl font-semibold mb-4">Destructive Dialog</h2>
        <p class="text-gray-600 mb-4">
          A dialog designed for destructive actions with warning styling and confirmation.
        </p>

        <div class="flex items-center gap-3 mb-4">
          <.dialog :let={%{hide: dialog_destroy_hide}} size="sm" id="destroy">
            <:trigger :let={dialog_destroy_attr}>
              <.button variant="destructive" type="button" {dialog_destroy_attr}>
                Destroy Server
              </.button>
            </:trigger>
            <form class="space-y-4">
              <.input type="text" name="confirm" placeholder="Enter 'destroy server' to confirm" />
              <div class="flex gap-2 justify-end">
                <.button variant="secondary" type="button" phx-click={dialog_destroy_hide}>
                  Cancel
                </.button>
                <.button variant="destructive">
                  Destroy Server
                </.button>
              </div>
            </form>
          </.dialog>
        </div>

        <div class="bg-gray-50 p-4 rounded-lg">
          <pre class="text-sm"><code><%=
            "<.dialog :let={%{hide: hide}} size=\"sm\" id=\"destroy\">\n" <>
            "  <:trigger :let={attr}>\n" <>
            "    <.button variant=\"destructive\" type=\"button\" {attr}>\n" <>
            "      Destroy Server\n" <>
            "    </.button>\n" <>
            "  </:trigger>\n" <>
            "  <form class=\"space-y-4\">\n" <>
            "    <.input type=\"text\" name=\"confirm\" placeholder=\"Enter 'destroy server' to confirm\" />\n" <>
            "    <div class=\"flex gap-2 justify-end\">\n" <>
            "      <.button variant=\"secondary\" type=\"button\" phx-click={hide}>\n" <>
            "        Cancel\n" <>
            "      </.button>\n" <>
            "      <.button variant=\"destructive\">\n" <>
            "        Destroy Server\n" <>
            "      </.button>\n" <>
            "    </div>\n" <>
            "  </form>\n" <>
            "</.dialog>"
          %></code></pre>
        </div>
      </div>
      
    <!-- Notify Dialog -->
      <div class="mb-12">
        <h2 class="text-xl font-semibold mb-4">Notify Dialog</h2>
        <p class="text-gray-600 mb-4">
          A dialog for showing notifications or status updates to the user.
        </p>

        <div class="flex items-center gap-3 mb-4">
          <.dialog :let={%{hide: dialog_notify_hide}} id="notify">
            <:trigger :let={dialog_notify_attr}>
              <.button variant="secondary" type="button" {dialog_notify_attr}>
                Notify Me
              </.button>
            </:trigger>
            <div class="-mt-1.5 mb-1 text-lg font-medium">Notifications</div>
            <div class="mb-6 text-base text-gray-600">
              You are all caught up. Good job!
            </div>
            <div class="flex justify-end gap-4">
              <.button
                phx-click={dialog_notify_hide}
                class="flex h-10 items-center justify-center rounded-md border border-gray-200 bg-gray-50 px-3.5 text-base font-medium text-gray-900 select-none hover:bg-gray-100 focus-visible:outline focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-blue-800 active:bg-gray-100"
              >
                Close
              </.button>
            </div>
          </.dialog>
        </div>

        <div class="bg-gray-50 p-4 rounded-lg">
          <pre class="text-sm"><code><%=
            "<.dialog :let={%{hide: hide}} id=\"notify\">\n" <>
            "  <:trigger :let={attr}>\n" <>
            "    <.button variant=\"secondary\" type=\"button\" {attr}>\n" <>
            "      Notify Me\n" <>
            "    </.button>\n" <>
            "  </:trigger>\n" <>
            "  <div class=\"-mt-1.5 mb-1 text-lg font-medium\">Notifications</div>\n" <>
            "  <div class=\"mb-6 text-base text-gray-600\">\n" <>
            "    You are all caught up. Good job!\n" <>
            "  </div>\n" <>
            "  <div class=\"flex justify-end gap-4\">\n" <>
            "    <.button phx-click={hide}>\n" <>
            "      Close\n" <>
            "    </.button>\n" <>
            "  </div>\n" <>
            "</.dialog>"
          %></code></pre>
        </div>
      </div>
      
    <!-- Alert Dialog -->
      <div class="mb-12">
        <h2 class="text-xl font-semibold mb-4">Alert Dialog</h2>
        <p class="text-gray-600 mb-4">
          An alert dialog with a destructive action, suitable for confirming critical operations.
        </p>

        <div class="flex items-center gap-3 mb-4">
          <.dialog :let={%{hide: dialog_alert_hide}} alert={true} id="alert-dialog">
            <:trigger :let={dialog_alert_attr}>
              <.button variant="secondary" type="button" {dialog_alert_attr}>
                Alert Dialog
              </.button>
            </:trigger>

            <div class="-mt-1.5 mb-1 text-lg font-medium">Delete Tweet</div>
            <div class="mb-6 text-base text-gray-600">
              Are you sure you want to delete this tweet? This action cannot be undone.
            </div>
            <div class="flex justify-end gap-4">
              <.button phx-click={dialog_alert_hide} variant="secondary">
                Cancel
              </.button>

              <.button variant="destructive">
                Delete Tweet
              </.button>
            </div>
          </.dialog>
        </div>

        <div class="bg-gray-50 p-4 rounded-lg">
          <pre class="text-sm"><code><%=
            "<.dialog :let={%{hide: hide}} alert={true} id=\"alert-dialog\">\n" <>
            "  <:trigger :let={attr}>\n" <>
            "    <.button variant=\"secondary\" type=\"button\" {attr}>\n" <>
            "      Alert Dialog\n" <>
            "    </.button>\n" <>
            "  </:trigger>\n" <>
            "\n" <>
            "  <div class=\"-mt-1.5 mb-1 text-lg font-medium\">Delete Tweet</div>\n" <>
            "  <div class=\"mb-6 text-base text-gray-600\">\n" <>
            "    Are you sure you want to delete this tweet? This action cannot be undone.\n" <>
            "  </div>\n" <>
            "  <div class=\"flex justify-end gap-4\">\n" <>
            "    <.button phx-click={hide} variant=\"secondary\">\n" <>
            "      Cancel\n" <>
            "    </.button>\n" <>
            "\n" <>
            "    <.button variant=\"destructive\">\n" <>
            "      Delete Tweet\n" <>
            "    </.button>\n" <>
            "  </div>\n" <>
            "</.dialog>"
          %></code></pre>
        </div>
      </div>
      
    <!-- Nested Dialog -->
      <div class="mb-12">
        <h2 class="text-xl font-semibold mb-4">Nested Dialog</h2>
        <p class="text-gray-600 mb-4">
          A dialog that contains another dialog, demonstrating how to handle nested modal interactions.
        </p>

        <div class="flex items-center gap-3 mb-4">
          <.dialog :let={%{hide: dialog_nested_hide}} alert={true} id="nested-dialog">
            <:trigger :let={dialog_nested_attr}>
              <.button variant="secondary" type="button" {dialog_nested_attr}>
                Open Parent Dialog
              </.button>
            </:trigger>

            <div class="-mt-1.5 mb-1 text-lg font-medium">Parent Dialog</div>
            <div class="mb-6 text-base text-gray-600">
              This dialog contains another dialog.
            </div>
            <div class="flex justify-end gap-4">
              <.button phx-click={dialog_nested_hide} variant="secondary">
                Close
              </.button>

              <.dialog :let={%{hide: dialog_child_hide}} alert={true} id="nested-dialog-child">
                <:trigger :let={dialog_child_attr}>
                  <.button variant="secondary" type="button" {dialog_child_attr}>
                    Open Child Dialog
                  </.button>
                </:trigger>

                <div class="-mt-1.5 mb-1 text-lg font-medium">Child Dialog</div>
                <div class="mb-6 text-base text-gray-600">
                  This is a nested dialog inside the parent.
                </div>
                <div class="flex justify-end gap-4">
                  <.button phx-click={dialog_child_hide} variant="secondary">
                    Close
                  </.button>

                  <.button variant="destructive">
                    Action
                  </.button>
                </div>
              </.dialog>
            </div>
          </.dialog>
        </div>

        <div class="bg-gray-50 p-4 rounded-lg">
          <pre class="text-sm"><code><%=
            "<.dialog :let={%{hide: hide}} alert={true} id=\"nested-dialog\">\n" <>
            "  <:trigger :let={attr}>\n" <>
            "    <.button variant=\"secondary\" type=\"button\" {attr}>\n" <>
            "      Open Parent Dialog\n" <>
            "    </.button>\n" <>
            "  </:trigger>\n" <>
            "\n" <>
            "  <div class=\"-mt-1.5 mb-1 text-lg font-medium\">Parent Dialog</div>\n" <>
            "  <div class=\"mb-6 text-base text-gray-600\">\n" <>
            "    This dialog contains another dialog.\n" <>
            "  </div>\n" <>
            "  <div class=\"flex justify-end gap-4\">\n" <>
            "    <.button phx-click={hide} variant=\"secondary\">\n" <>
            "      Close\n" <>
            "    </.button>\n" <>
            "\n" <>
            "    <.dialog :let={%{hide: hide}} alert={true} id=\"nested-dialog-child\">\n" <>
            "      <:trigger :let={attr}>\n" <>
            "        <.button variant=\"secondary\" type=\"button\" {attr}>\n" <>
            "          Open Child Dialog\n" <>
            "        </.button>\n" <>
            "      </:trigger>\n" <>
            "\n" <>
            "      <div class=\"-mt-1.5 mb-1 text-lg font-medium\">Child Dialog</div>\n" <>
            "      <div class=\"mb-6 text-base text-gray-600\">\n" <>
            "        This is a nested dialog inside the parent.\n" <>
            "      </div>\n" <>
            "      <div class=\"flex justify-end gap-4\">\n" <>
            "        <.button phx-click={hide} variant=\"secondary\">\n" <>
            "          Close\n" <>
            "        </.button>\n" <>
            "\n" <>
            "        <.button variant=\"destructive\">\n" <>
            "          Action\n" <>
            "        </.button>\n" <>
            "      </div>\n" <>
            "    </.dialog>\n" <>
            "  </div>\n" <>
            "</.dialog>"
          %></code></pre>
        </div>
      </div>
      
    <!-- Custom Content Dialog -->
      <div class="mb-12">
        <h2 class="text-xl font-semibold mb-4">Custom Content Dialog</h2>
        <p class="text-gray-600 mb-4">
          A dialog using the custom content slot for complete control over the dialog structure and styling.
        </p>

        <div class="flex items-center gap-3 mb-4">
          <.dialog :let={%{hide: dialog_custom_hide}} alert={false} id="alert-custom-content">
            <:trigger :let={dialog_custom_attr}>
              <.button variant="secondary" type="button" {dialog_custom_attr}>
                Custom Content
              </.button>
            </:trigger>

            <:content :let={{dialog_custom_attr, %{hide: dialog_custom_hide}}}>
              <div
                class={[
                  "not-[hidden]:animate-in [hidden]:animate-out [hidden]:fade-out-0 not-[hidden]:fade-in-0 [hidden]:zoom-out-95 not-[hidden]:zoom-in-95",
                  "bg-popover fixed top-[50%] left-[50%] z-50 grid w-full max-w-sm translate-x-[-50%] translate-y-[-50%] gap-4 rounded-lg border p-6 shadow-lg duration-200 sm:max-w-sm"
                ]}
                {dialog_custom_attr}
              >
                <div class="-mt-1.5 mb-1 text-lg font-medium">Custom Content Slot</div>
                <div class="mb-6 text-base text-gray-600">
                  Using the custom content slot to completely customize the dialog appearance.
                </div>
                <div class="flex justify-end gap-4">
                  <.button phx-click={dialog_custom_hide} variant="secondary">
                    Cancel
                  </.button>

                  <.button variant="destructive">
                    Action
                  </.button>
                </div>
              </div>
            </:content>
          </.dialog>
        </div>

        <div class="bg-gray-50 p-4 rounded-lg">
          <pre class="text-sm overflow-y-auto"><code><%=
            "<.dialog :let={%{hide: hide}} alert={false} id=\"alert-custom-content\">\n" <>
            "  <:trigger :let={attr}>\n" <>
            "    <.button variant=\"secondary\" type=\"button\" {attr}>\n" <>
            "      Custom Content\n" <>
            "    </.button>\n" <>
            "  </:trigger>\n" <>
            "\n" <>
            "  <:content :let={{attr, %{hide: hide}}}>\n" <>
            "    <div\n" <>
            "      class={[\n" <>
            "        \"not-[hidden]:animate-in [hidden]:animate-out [hidden]:fade-out-0 not-[hidden]:fade-in-0 [hidden]:zoom-out-95 not-[hidden]:zoom-in-95\",\n" <>
            "        \"bg-popover fixed top-[50%] left-[50%] z-50 grid w-full max-w-sm translate-x-[-50%] translate-y-[-50%] gap-4 rounded-lg border p-6 shadow-lg duration-200 sm:max-w-sm\"\n" <>
            "      ]}\n" <>
            "      {attr}\n" <>
            "    >\n" <>
            "      <div class=\"-mt-1.5 mb-1 text-lg font-medium\">Custom Content Slot</div>\n" <>
            "      <div class=\"mb-6 text-base text-gray-600\">\n" <>
            "        Using the custom content slot to completely customize the dialog appearance.\n" <>
            "      </div>\n" <>
            "      <div class=\"flex justify-end gap-4\">\n" <>
            "        <.button phx-click={hide} variant=\"secondary\">\n" <>
            "          Cancel\n" <>
            "        </.button>\n" <>
            "\n" <>
            "        <.button variant=\"destructive\">\n" <>
            "          Action\n" <>
            "        </.button>\n" <>
            "      </div>\n" <>
            "    </div>\n" <>
            "  </:content>\n" <>
            "</.dialog>"
          %></code></pre>
        </div>
      </div>
    </Layouts.docs>
    """
  end
end
