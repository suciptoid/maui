defmodule MAUIWeb.Router do
  use MAUIWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", MAUIWeb do
    pipe_through :api
  end
end
