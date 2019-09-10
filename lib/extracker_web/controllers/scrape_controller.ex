defmodule ExtrackerWeb.ScrapeController do
  use ExtrackerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
