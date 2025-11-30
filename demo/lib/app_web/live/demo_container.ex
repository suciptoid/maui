defmodule AppWeb.Live.DemoContainer do
  use AppWeb, :live_view
  use Maui

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.docs flash={@flash} live_action={@live_action}>
      <.demo_container />
    </Layouts.docs>
    """
  end

  def demo_container(assigns) do
    ~H"""
    <div class="space-y-8">
      <div>
        <h2 class="text-2xl font-bold">Container Components</h2>
        <p class="text-muted-foreground mt-2">
          Maui provides various container components for organizing content with consistent styling.
        </p>
      </div>

      <div class="space-y-6">
        <h3 class="text-lg font-semibold">Basic Card</h3>
        <p class="text-muted-foreground">A simple card component with basic styling.</p>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div class="border rounded-lg p-4">
            <h4 class="font-medium mb-3">Default Card</h4>
            <Maui.Container.card>
              This is a basic card with default styling.
            </Maui.Container.card>
          </div>

          <div class="border rounded-lg p-4">
            <h4 class="font-medium mb-3">Card with Custom Class</h4>
            <Maui.Container.card class="bg-blue-50 text-blue-900 border-blue-200">
              This is a card with custom styling applied via the class attribute.
            </Maui.Container.card>
          </div>
        </div>
      </div>

      <div class="space-y-6">
        <h3 class="text-lg font-semibold">Card Header Components</h3>
        <p class="text-muted-foreground">
          Using the card_header, card_title, and card_description components to create structured headers.
        </p>

        <div class="border rounded-lg p-4">
          <h4 class="font-medium mb-3">Card with Header</h4>
          <Maui.Container.card>
            <Maui.Container.card_header>
              <Maui.Container.card_title>Card Title</Maui.Container.card_title>
              <Maui.Container.card_description>
                Card description goes here
              </Maui.Container.card_description>
            </Maui.Container.card_header>
          </Maui.Container.card>
        </div>
      </div>

      <div class="space-y-6">
        <h3 class="text-lg font-semibold">Card Content</h3>
        <p class="text-muted-foreground">Using the card_content component for structured content.</p>

        <div class="border rounded-lg p-4">
          <h4 class="font-medium mb-3">Card with Content</h4>
          <Maui.Container.card>
            <Maui.Container.card_header>
              <Maui.Container.card_title>Card with Content</Maui.Container.card_title>
              <Maui.Container.card_description>
                Example of card with header and content sections
              </Maui.Container.card_description>
            </Maui.Container.card_header>
            <Maui.Container.card_content>
              <p>This is the content section of the card. It has proper padding and spacing.</p>
              <p class="mt-2">
                You can put any content here that you want to display in the card body.
              </p>
            </Maui.Container.card_content>
          </Maui.Container.card>
        </div>
      </div>

      <div class="space-y-6">
        <h3 class="text-lg font-semibold">Full Card Examples</h3>
        <p class="text-muted-foreground">
          Complete cards with header, content, footer, and action elements.
        </p>

        <div class="border rounded-lg p-4">
          <h4 class="font-medium mb-3">Complete Card Example</h4>
          <Maui.Container.card>
            <Maui.Container.card_header>
              <Maui.Container.card_title>Full Card Example</Maui.Container.card_title>
              <Maui.Container.card_description>
                This card demonstrates all available card components working together.
              </Maui.Container.card_description>
            </Maui.Container.card_header>

            <Maui.Container.card_content>
              <div class="grid gap-4">
                <div class="flex items-center gap-4">
                  <div class="bg-muted rounded-full w-12 h-12 flex items-center justify-center">
                    <.icon name="hero-user" class="size-6" />
                  </div>
                  <div>
                    <h4 class="font-medium">John Doe</h4>
                    <p class="text-sm text-muted-foreground">john@example.com</p>
                  </div>
                </div>

                <p class="text-sm">
                  This card contains multiple components and demonstrates how they work together
                  to create a complete UI section with consistent styling.
                </p>
              </div>
            </Maui.Container.card_content>

            <Maui.Container.card_footer>
              <.button variant="outline">Cancel</.button>
              <.button>Save Changes</.button>
            </Maui.Container.card_footer>
          </Maui.Container.card>
        </div>

        <div class="border rounded-lg p-4">
          <h4 class="font-medium mb-3">Card with Action Element</h4>
          <Maui.Container.card>
            <Maui.Container.card_header>
              <Maui.Container.card_title>Card with Action</Maui.Container.card_title>
              <Maui.Container.card_description>
                This card demonstrates the card_action component that appears on the right side of the header.
              </Maui.Container.card_description>
              <Maui.Container.card_action>
                <.button variant="outline" size="sm">Settings</.button>
              </Maui.Container.card_action>
            </Maui.Container.card_header>

            <Maui.Container.card_content>
              <p>
                The card_action component allows you to place action elements like buttons
                on the right side of the card header.
              </p>
            </Maui.Container.card_content>
          </Maui.Container.card>
        </div>
      </div>

      <div class="space-y-6">
        <h3 class="text-lg font-semibold">Usage Examples</h3>

        <div class="space-y-4">
          <div>
            <h4 class="font-medium mb-2">Basic Usage</h4>
            <div class="bg-muted rounded-lg p-4 text-sm">
              <code class="block whitespace-pre-wrap font-mono text-sm">&lt;Maui.Container.card&gt;
    Card content goes here
    &lt;/Maui.Container.card&gt;</code>
            </div>
          </div>

          <div>
            <h4 class="font-medium mb-2">Card with Header Components</h4>
            <div class="bg-muted rounded-lg p-4 text-sm">
              <code class="block whitespace-pre-wrap font-mono text-sm">&lt;Maui.Container.card&gt;
    &lt;Maui.Container.card_header&gt;
    &lt;Maui.Container.card_title&gt;Card Title&lt;/Maui.Container.card_title&gt;
    &lt;Maui.Container.card_description&gt;Description&lt;/Maui.Container.card_description&gt;
    &lt;/Maui.Container.card_header&gt;

    &lt;Maui.Container.card_content&gt;
    Content goes here
    &lt;/Maui.Container.card_content&gt;

    &lt;Maui.Container.card_footer&gt;
    &lt;.button&gt;Action&lt;/.button&gt;
    &lt;/Maui.Container.card_footer&gt;
    &lt;/Maui.Container.card&gt;</code>
            </div>
          </div>

          <div>
            <h4 class="font-medium mb-2">Card with Action</h4>
            <div class="bg-muted rounded-lg p-4 text-sm">
              <code class="block whitespace-pre-wrap font-mono text-sm">&lt;Maui.Container.card&gt;
    &lt;Maui.Container.card_header&gt;
    &lt;Maui.Container.card_title&gt;Card Title&lt;/Maui.Container.card_title&gt;
    &lt;Maui.Container.card_action&gt;
    &lt;.button size="sm"&gt;Settings&lt;/.button&gt;
    &lt;/Maui.Container.card_action&gt;
    &lt;/Maui.Container.card_header&gt;
    &lt;Maui.Container.card_content&gt;...&lt;/Maui.Container.card_content&gt;
    &lt;/Maui.Container.card&gt;</code>
            </div>
          </div>
        </div>

        <div class="p-6 bg-accent/30 rounded-lg border border-border">
          <h4 class="text-sm font-semibold mb-2">Features</h4>
          <ul class="text-sm text-muted-foreground space-y-1 list-disc list-inside">
            <li>Responsive design with consistent spacing</li>
            <li>Customizable styling via the class attribute</li>
            <li>Semantic HTML structure for accessibility</li>
            <li>Predefined components for headers, content, and footers</li>
            <li>Support for action elements in headers</li>
          </ul>
        </div>
      </div>
    </div>
    """
  end
end
