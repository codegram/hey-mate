defmodule HeyMateWeb.HomeController do
  use HeyMateWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
