defmodule AppWeb.Live.DemoDialog do
  use AppWeb, :live_view
  use Maui

  @basic_code """
  <.dialog :let={%{hide: hide}} id="x">
    <:trigger :let={attr}>
      <.button variant="secondary" type="button" {attr}>
        Open Dialog
      </.button>
    </:trigger>
    <form class="space-y-4">
      <.input type="text" name="name" placeholder="Name" />
      <.input type="password" name="name" placeholder="Password" />
      <div class="flex gap-2 justify-end">
        <.button variant="secondary" type="button" phx-click={hide}>
          Cancel
        </.button>
        <.button>
          Change
        </.button>
      </div>
    </form>
  </.dialog>
  """

  @destructive_code """
  <.dialog :let={%{hide: hide}} size="sm" id="destroy">
    <:trigger :let={attr}>
      <.button variant="destructive" type="button" {attr}>
        Destroy Server
      </.button>
    </:trigger>
    <form class="space-y-4">
      <.input type="text" name="confirm" placeholder="Enter 'destroy server' to confirm" />
      <div class="flex gap-2 justify-end">
        <.button variant="secondary" type="button" phx-click={hide}>
          Cancel
        </.button>
        <.button variant="destructive">
          Destroy Server
        </.button>
      </div>
    </form>
  </.dialog>
  """

  @notify_code """
  <.dialog :let={%{hide: hide}} id="notify">
    <:trigger :let={attr}>
      <.button variant="secondary" type="button" {attr}>
        Notify Me
      </.button>
    </:trigger>
    <div class="-mt-1.5 mb-1 text-lg font-medium">Notifications</div>
    <div class="mb-6 text-base text-gray-600">
      You are all caught up. Good job!
    </div>
    <div class="flex justify-end gap-4">
      <.button phx-click={hide}>
        Close
      </.button>
    </div>
  </.dialog>
  """

  @alert_code """
  <.dialog :let={%{hide: hide}} alert={true} id="alert-dialog">
    <:trigger :let={attr}>
      <.button variant="secondary" type="button" {attr}>
        Alert Dialog
      </.button>
    </:trigger>

    <div class="-mt-1.5 mb-1 text-lg font-medium">Delete Tweet</div>
    <div class="mb-6 text-base text-gray-600">
      Are you sure you want to delete this tweet? This action cannot be undone.
    </div>
    <div class="flex justify-end gap-4">
      <.button phx-click={hide} variant="secondary">
        Cancel
      </.button>

      <.button variant="destructive">
        Delete Tweet
      </.button>
    </div>
  </.dialog>
  """

  @nested_code """
  <.dialog :let={%{hide: hide}} alert={true} id="nested-dialog">
    <:trigger :let={attr}>
      <.button variant="secondary" type="button" {attr}>
        Open Parent Dialog
      </.button>
    </:trigger>

    <div class="-mt-1.5 mb-1 text-lg font-medium">Parent Dialog</div>
    <div class="mb-6 text-base text-gray-600">
      This dialog contains another dialog.
    </div>
    <div class="flex justify-end gap-4">
      <.button phx-click={hide} variant="secondary">
        Close
      </.button>

      <.dialog :let={%{hide: hide}} alert={true} id="nested-dialog-child">
        <:trigger :let={attr}>
          <.button variant="secondary" type="button" {attr}>
            Open Child Dialog
          </.button>
        </:trigger>

        <div class="-mt-1.5 mb-1 text-lg font-medium">Child Dialog</div>
        <div class="mb-6 text-base text-gray-600">
          This is a nested dialog inside the parent.
        </div>
        <div class="flex justify-end gap-4">
          <.button phx-click={hide} variant="secondary">
            Close
          </.button>

          <.button variant="destructive">
            Action
          </.button>
        </div>
      </.dialog>
    </div>
  </.dialog>
  """

  @custom_content_code """
  <.dialog :let={%{hide: hide}} alert={false} id="alert-custom-content">
    <:trigger :let={attr}>
      <.button variant="secondary" type="button" {attr}>
        Custom Content
      </.button>
    </:trigger>

    <:content :let={{attr, %{hide: hide}}}>
      <div
        class={[
          "not-[hidden]:animate-in [hidden]:animate-out [hidden]:fade-out-0 not-[hidden]:fade-in-0 [hidden]:zoom-out-95 not-[hidden]:zoom-in-95",
          "bg-popover fixed top-[50%] left-[50%] z-50 grid w-full max-w-sm translate-x-[-50%] translate-y-[-50%] gap-4 rounded-lg border p-6 shadow-lg duration-200 sm:max-w-sm"
        ]}
        {attr}
      >
        <div class="-mt-1.5 mb-1 text-lg font-medium">Custom Content Slot</div>
        <div class="mb-6 text-base text-gray-600">
          Using the custom content slot to completely customize the dialog appearance.
        </div>
        <div class="flex justify-end gap-4">
          <.button phx-click={hide} variant="secondary">
            Cancel
          </.button>

          <.button variant="destructive">
            Action
          </.button>
        </div>
      </div>
    </:content>
  </.dialog>
  """

  def render(assigns) do
    assigns =
      assigns
      |> assign(:basic_code, @basic_code)
      |> assign(:destructive_code, @destructive_code)
      |> assign(:notify_code, @notify_code)
      |> assign(:alert_code, @alert_code)
      |> assign(:nested_code, @nested_code)
      |> assign(:custom_content_code, @custom_content_code)

    ~H"""
    <Layouts.docs flash={@flash} live_action={@live_action}>
      <.example_card
        title="Basic Dialog"
        description="A simple dialog with form elements for collecting user input."
      >
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
        <.code_block code={@basic_code} />
      </.example_card>

      <.example_card
        title="Destructive Dialog"
        description="A dialog designed for destructive actions with warning styling and confirmation."
      >
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
        <.code_block code={@destructive_code} />
      </.example_card>

      <.example_card
        title="Notify Dialog"
        description="A dialog for showing notifications or status updates to the user."
      >
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
        <.code_block code={@notify_code} />
      </.example_card>

      <.example_card
        title="Alert Dialog"
        description="An alert dialog with a destructive action, suitable for confirming critical operations."
      >
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
        <.code_block code={@alert_code} />
      </.example_card>

      <.example_card
        title="Nested Dialog"
        description="A dialog that contains another dialog, demonstrating how to handle nested modal interactions."
      >
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
        <.code_block code={@nested_code} />
      </.example_card>

      <.example_card
        title="Custom Content Dialog"
        description="A dialog using the custom content slot for complete control over the dialog structure and styling."
      >
        <div class="flex items-center gap-3 mb-4">
          <.dialog :let={%{hide: _}} alert={false} id="alert-custom-content">
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
        <.code_block code={@custom_content_code} />
      </.example_card>
    </Layouts.docs>
    """
  end
end
