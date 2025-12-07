defmodule AppWeb.Router do
  use AppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AppWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AppWeb do
    pipe_through :browser

    live "/", Live.Demo, :index
    live "/inputs", Live.Demo, :inputs
    live "/buttons", Live.Demo, :buttons
    live "/dropdown", Live.Demo, :dropdown
    live "/dialog", Live.DemoDialog, :dialog
    live "/popover", Live.DemoPopover, :popover
    live "/toast", Live.Demo, :toast
    live "/flash", Live.Demo, :toast
    live "/alert", Live.Demo, :alert
    live "/select", Live.DemoSelect, :select
    live "/container", Live.DemoContainer, :container
    live "/progress_badges", Live.DemoProgressBadges, :progress_badges
    live "/link/:any", Live.Demo, :index
    live "/tab/:tab", Live.DemoTab
    live "/tab", Live.DemoTab, :index
    get "/lc", PageController, :lc
  end

  # Other scopes may use custom stacks.
  # scope "/api", AppWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:app, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AppWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
