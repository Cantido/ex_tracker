defmodule ExtrackerWeb.PageController do
  use ExtrackerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
