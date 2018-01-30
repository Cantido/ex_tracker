defmodule ExtrackerServer do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/announce", to: ExtrackerServer.Announce

  get "/scrape", to: ExtrackerServer.Scrape

  match _ do
    send_resp(conn, 404, "oops")
  end
end
