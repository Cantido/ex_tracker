defmodule ExtrackerServer do
  use Plug.Router

  plug :match
  plug :fetch_query_params
  plug :rename_query_params, %{
    "info_hash" => :info_hash,
    "peer_id" => :peer_id,
    "port" => :port,
    "uploaded" => :uploaded,
    "downloaded" => :downloaded,
    "left" => :left,
    "event" => :event
  }
  plug :dispatch

  #Extracker.request(req.query_params) |> rename_keys(%{interval_s: :interval})

  get "/announce" do
    conn
    |> query()
    |> send_resp()
  end

  get "/scrape", to: ExtrackerServer.Scrape

  match _ do
    send_resp(conn, 404, "oops")
  end

  def query(conn) do
    tracker_params = conn.query_params |> Map.put_new(:ip, conn.remote_ip)
    request = Extracker.request(tracker_params) |> rename_keys(%{interval_s: :interval})
    {:ok, encoded} = ExBencode.encode(request)
    conn |> resp(200, encoded) |> put_resp_content_type("text/plain")
  end

  def rename_query_params(conn, key_names) do
    Map.update(conn, :query_params, %{}, &rename_keys(&1, key_names))
  end

  def rename_keys(map, keys) do
    for {k, v} <- map, into: %{}, do: {Map.get(keys, k, k), v}
  end
end
