defmodule AppWeb.DocComponents do
  @moduledoc """
  Reusable documentation components for showcasing UI examples.
  """
  use Phoenix.Component

  @doc """
  Renders an example card with title, optional description, and content.

  ## Examples

      <.example_card title="Button Variants">
        <.button>Primary</.button>
      </.example_card>
  """
  attr :title, :string, required: true
  attr :description, :string, default: nil

  slot :inner_block, required: true

  def example_card(assigns) do
    ~H"""
    <div class="rounded-lg border border-zinc-200 dark:border-zinc-700 p-6 hover:bg-zinc-50 dark:hover:bg-zinc-800/50 transition-colors">
      <h3 class="text-lg font-semibold text-zinc-900 dark:text-zinc-100">{@title}</h3>
      <p :if={@description} class="mt-1 text-sm text-zinc-600 dark:text-zinc-400">
        {@description}
      </p>
      <div class="mt-4">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  @doc """
  Renders a code block with syntax highlighting styling and a copy button.

  ## Examples

      <.code_block code={~s|<.button>Click me</.button>|} language="elixir" />
  """
  attr :code, :string, required: true
  attr :language, :string, default: "elixir"

  def code_block(assigns) do
    ~H"""
    <div class="relative group">
      <button
        type="button"
        class="absolute top-2 right-2 p-2 rounded-md bg-zinc-700 hover:bg-zinc-600 text-zinc-300 hover:text-white opacity-0 group-hover:opacity-100 transition-opacity cursor-pointer"
        phx-hook="CopyCode"
        id={"copy-#{System.unique_integer([:positive])}"}
        data-code={@code}
        aria-label="Copy code"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="size-4"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M15.75 17.25v3.375c0 .621-.504 1.125-1.125 1.125h-9.75a1.125 1.125 0 0 1-1.125-1.125V7.875c0-.621.504-1.125 1.125-1.125H6.75a9.06 9.06 0 0 1 1.5.124m7.5 10.376h3.375c.621 0 1.125-.504 1.125-1.125V11.25c0-4.46-3.243-8.161-7.5-8.876a9.06 9.06 0 0 0-1.5-.124H9.375c-.621 0-1.125.504-1.125 1.125v3.5m7.5 10.375H9.375a1.125 1.125 0 0 1-1.125-1.125v-9.25m12 6.625v-1.875a3.375 3.375 0 0 0-3.375-3.375h-1.5a1.125 1.125 0 0 1-1.125-1.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H9.75"
          />
        </svg>
      </button>
      <pre class="rounded-lg bg-zinc-900 p-4 overflow-x-auto"><code
          class={"language-#{@language} font-mono text-sm text-zinc-100"}
          phx-no-curly-interpolation
        >{@code}</code></pre>
    </div>
    """
  end

  @doc """
  Renders a table showing component props.

  ## Examples

      <.props_table props={[
        %{name: "variant", type: "atom", default: ":primary", description: "The button style variant"},
        %{name: "size", type: "atom", default: ":md", description: "The button size"}
      ]} />
  """
  attr :props, :list, required: true

  def props_table(assigns) do
    ~H"""
    <div class="overflow-x-auto">
      <table class="w-full text-sm">
        <thead>
          <tr class="border-b border-zinc-200 dark:border-zinc-700">
            <th class="text-left py-2 px-3 font-semibold text-zinc-900 dark:text-zinc-100">Name</th>
            <th class="text-left py-2 px-3 font-semibold text-zinc-900 dark:text-zinc-100">Type</th>
            <th class="text-left py-2 px-3 font-semibold text-zinc-900 dark:text-zinc-100">
              Default
            </th>
            <th class="text-left py-2 px-3 font-semibold text-zinc-900 dark:text-zinc-100">
              Description
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            :for={prop <- @props}
            class="border-b border-zinc-100 dark:border-zinc-800 last:border-0"
          >
            <td class="py-2 px-3 font-mono text-zinc-800 dark:text-zinc-200">{prop.name}</td>
            <td class="py-2 px-3 font-mono text-zinc-600 dark:text-zinc-400">{prop.type}</td>
            <td class="py-2 px-3 font-mono text-zinc-600 dark:text-zinc-400">
              {prop[:default] || "-"}
            </td>
            <td class="py-2 px-3 text-zinc-600 dark:text-zinc-400">{prop[:description] || "-"}</td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end
end
