defmodule AppWeb.Live.DemoDialog do
  use AppWeb, :live_view
  use Maui

  def render(assigns) do
    ~H"""
    <Layouts.docs flash={@flash} live_action={@live_action}>
      <div class="flex items-center gap-3">
        <.dialog :let={%{hide: hide}} id="x">
          <:trigger :let={attr}>
            <.button variant="secondary" type="button" {attr}>
              Open Dialog
            </.button>
          </:trigger>
          <form class="space-y-4">
            <.input type="text" name="name" placeholder="Name" />
            <.input type="password" name="name" placeholder="Name" />
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
        <%!-- Destructive --%>
        <.dialog :let={%{hide: hide}} size="sm" id="destroy">
          <:trigger :let={attr}>
            <.button variant="destructive" type="button" {attr}>
              Destroy Server
            </.button>
          </:trigger>
          <form class="space-y-4">
            <.input type="text" name="name" placeholder="destroy server" />
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

        <%!-- Notify --%>
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
            <.button
              phx-click={hide}
              class="flex h-10 items-center justify-center rounded-md border border-gray-200 bg-gray-50 px-3.5 text-base font-medium text-gray-900 select-none hover:bg-gray-100 focus-visible:outline focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-blue-800 active:bg-gray-100"
            >
              Close
            </.button>
          </div>
        </.dialog>

        <%!-- Alert --%>
        <.dialog :let={%{hide: hide}} alert={true} id="alert-dialog">
          <:trigger :let={attr}>
            <.button variant="secondary" type="button" {attr}>
              Alert Dialog
            </.button>
          </:trigger>

          <div class="-mt-1.5 mb-1 text-lg font-medium">Notifications</div>
          <div class="mb-6 text-base text-gray-600">
            You are all caught up. Good job!
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

        <%!-- Nested Dialog --%>
        <.dialog :let={%{hide: hide}} alert={true} id="nested-dialog">
          <:trigger :let={attr}>
            <.button variant="secondary" type="button" {attr}>
              Alert Dialog
            </.button>
          </:trigger>

          <div class="-mt-1.5 mb-1 text-lg font-medium">Notifications</div>
          <div class="mb-6 text-base text-gray-600">
            You are all caught up. Good job!
          </div>
          <div class="flex justify-end gap-4">
            <.button phx-click={hide} variant="secondary">
              Cancel
            </.button>

            <.dialog :let={%{hide: hide}} alert={true} id="nested-dialog-child">
              <:trigger :let={attr}>
                <.button variant="secondary" type="button" {attr}>
                  Child Dialog
                </.button>
              </:trigger>

              <div class="-mt-1.5 mb-1 text-lg font-medium">Notifications</div>
              <div class="mb-6 text-base text-gray-600">
                You are all caught up. Good job!
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
          </div>
        </.dialog>

        <%!-- Custom Content --%>
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
                You are all caught up. Good job!
              </div>
              <div class="flex justify-end gap-4">
                <.button phx-click={hide} variant="secondary">
                  Cancel
                </.button>

                <.button variant="destructive">
                  Delete Tweet
                </.button>
              </div>
            </div>
          </:content>
        </.dialog>
      </div>
    </Layouts.docs>
    """
  end
end
