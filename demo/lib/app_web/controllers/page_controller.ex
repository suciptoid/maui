defmodule AppWeb.PageController do
  use AppWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def lc(conn, _params) do
    render(conn, :livecomponent)
  end
end
