defmodule AppWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use AppWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="flex w-full items-center py-2 px-4 sm:px-6 lg:px-8">
      <div class="flex-1">
        <a href="/" class="flex-1 flex w-fit items-center gap-2">
          <img src={~p"/images/logo.svg"} width="36" />
          <span class="text-sm font-semibold">v{Application.spec(:phoenix, :vsn)}</span>
        </a>
      </div>
      <div class="flex-none">
        <ul class="flex flex-column px-1 space-x-4 items-center">
          <li>
            <a href="https://phoenixframework.org/" class="btn btn-ghost">Website</a>
          </li>
          <li>
            <a href="https://github.com/phoenixframework/phoenix" class="btn btn-ghost">GitHub</a>
          </li>
          <li>
            <.theme_toggle />
          </li>
        </ul>
      </div>
    </header>

    <main class="px-4 py-20 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-2xl space-y-4">
        {render_slot(@inner_block)}
      </div>
    </main>
    """
  end

  @doc """
  Renders docs layout with sidebar navigation.

  This layout is used for component documentation pages with
  a sidebar for navigation between different component sections.

  ## Examples

      <Layouts.docs flash={@flash} live_action={@live_action}>
        <h1>Content</h1>
      </Layouts.docs>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :live_action, :atom, required: true, doc: "the current live action"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def docs(assigns) do
    ~H"""
    <div class="flex h-screen">
      <%!-- Sidebar --%>
      <aside class="w-64 border-r border-border bg-background">
        <div class="flex h-full flex-col">
          <%!-- Logo/Header --%>
          <div class="flex items-center gap-2 border-b border-border px-6 py-4">
            <img src={~p"/images/maui-hook-2d.png"} width="40" />
            <span class="text-lg font-semibold">Maui </span>
          </div>

          <%!-- Navigation --%>
          <nav class="flex-1 overflow-y-auto p-4">
            <div class="space-y-1">
              <.sidebar_link
                patch={~p"/"}
                active={@live_action == :index}
                icon="hero-home"
              >
                Overview
              </.sidebar_link>
              <.sidebar_link
                patch={~p"/alert"}
                active={@live_action == :alert}
                icon="hero-exclamation-circle"
              >
                Alert
              </.sidebar_link>
              <.sidebar_link
                patch={~p"/inputs"}
                active={@live_action == :inputs}
                icon="hero-cursor-arrow-rays"
              >
                Inputs
              </.sidebar_link>

              <.sidebar_link
                patch={~p"/buttons"}
                active={@live_action == :buttons}
                icon="hero-cursor-arrow-ripple"
              >
                Buttons
              </.sidebar_link>

              <.sidebar_link
                patch={~p"/dropdown"}
                active={@live_action == :dropdown}
                icon="hero-chevron-down"
              >
                Dropdown
              </.sidebar_link>

              <.sidebar_link
                patch={~p"/select"}
                active={@live_action == :select}
                icon="hero-chevron-down"
              >
                Select
              </.sidebar_link>

              <.sidebar_link
                patch={~p"/popover"}
                active={@live_action == :popover}
                icon="hero-chat-bubble-left"
              >
                Popover
              </.sidebar_link>

              <.sidebar_link
                patch={~p"/toast"}
                active={@live_action == :toast}
                icon="hero-bell"
              >
                Toast
              </.sidebar_link>

              <.sidebar_link
                patch={~p"/tab"}
                active={@live_action == :tab}
                icon="hero-bell"
              >
                Tabs Demo
              </.sidebar_link>

              <.sidebar_link
                patch={~p"/container"}
                active={@live_action == :container}
                icon="hero-square-2-stack"
              >
                Container
              </.sidebar_link>

              <.sidebar_link
                patch={~p"/progress_badges"}
                active={@live_action == :progress_badges}
                icon="hero-bolt"
              >
                Progress & Badges
              </.sidebar_link>

              <.sidebar_link
                patch={~p"/dialog"}
                active={@live_action == :dialog}
                icon="hero-window"
              >
                Dialog
              </.sidebar_link>
            </div>
          </nav>

          <%!-- Theme Toggle at bottom --%>
          <div class="border-t border-border p-4">
            <.theme_toggle />
          </div>
        </div>
      </aside>

      <%!-- Main Content --%>
      <div class="flex flex-1 flex-col overflow-hidden">
        <%!-- Header --%>
        <header class="border-b border-border px-8 py-4">
          <div class="flex items-center justify-between">
            <h1 class="text-2xl font-bold">
              {page_title(@live_action)}
            </h1>
            <div class="flex items-center gap-4">
              <a
                href="https://github.com/phoenixframework/phoenix"
                class="text-muted-foreground hover:text-foreground"
              >
                <.icon name="hero-code-bracket" class="size-5" />
              </a>
            </div>
          </div>
        </header>

        <%!-- Content Area --%>
        <main class="flex-1 overflow-y-auto px-8 py-6">
          <div class="mx-auto max-w-7xl">
            {render_slot(@inner_block)}
          </div>
        </main>
      </div>
    </div>
    """
  end

  attr :patch, :string, required: true
  attr :active, :boolean, default: false
  attr :icon, :string, default: nil
  slot :inner_block, required: true

  defp sidebar_link(assigns) do
    ~H"""
    <.link
      patch={@patch}
      class={[
        "flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors",
        @active && "bg-accent text-accent-foreground",
        !@active && "text-muted-foreground hover:bg-accent/50 hover:text-foreground"
      ]}
    >
      <.icon :if={@icon} name={@icon} class="size-4" />
      {render_slot(@inner_block)}
    </.link>
    """
  end

  defp page_title(:index), do: "Component Overview"
  defp page_title(:inputs), do: "Inputs"
  defp page_title(:buttons), do: "Buttons"
  defp page_title(:dropdown), do: "Dropdown"
  defp page_title(:select), do: "Select"
  defp page_title(:popover), do: "Popover"
  defp page_title(:toast), do: "Toast"
  defp page_title(:container), do: "Container"
  defp page_title(:dialog), do: "Dialog"
  defp page_title(:progress_badges), do: "Progress & Badges"
  defp page_title(_), do: "Components"

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples


  @doc \"""
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
