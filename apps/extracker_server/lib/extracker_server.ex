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
  plug :scrub_params
  plug :dispatch

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
    body = conn.query_params
    |> Map.put_new(:ip, conn.remote_ip)
    |> Extracker.request()
    |> rename_keys(%{interval_s: :interval})


    formatted = if compact_peers?(conn) do
      compact(body)
    else
      format(body)
    end

    {:ok, encoded} = formatted |> ExBencode.encode()

    conn
    |> resp(200, encoded)
    |> put_resp_content_type("text/plain")
  end

  def scrub_params(conn, _opts) do
    {port, _rem} = Integer.parse(conn.query_params.port)
    Map.update(conn, :query_params, %{}, &Map.put(&1, :port, port))
  end

  def compact_peers?(conn) do
    conn.query_params["compact"] == "1"
  end

  def format(%{peers: peers} = body) when is_list(peers) do
    %{body | peers: format_peers(peers)}
  end

  defp format_peers(peers) when is_list(peers) do
    Enum.map(peers, &format_peer_ip/1)
  end

  defp format_peer_ip(%{ip: ip} = peer) when is_tuple(ip) do
    peer
    |> Map.put(:ip, to_string(:inet.ntoa(ip)))
  end

  def compact(%{peers: peers} = body) when is_list(peers) do
    peers = Enum.map(peers, &compact_peer/1) |> Enum.join()
    %{body | peers: peers}
  end

  defp compact_peer(%{peer_id: _, ip: {a, b, c, d}, port: port})
  when a in 0..255
   and b in 0..255
   and c in 0..255
   and d in 0..255
   and port in 0..65535 do
    <<a, b, c, d, port :: 16>>
end

  def rename_query_params(conn, key_names) when is_map(key_names) do
    Map.update(conn, :query_params, %{}, &rename_keys(&1, key_names))
  end

  def rename_keys(map, keys) when is_map(map) and is_map(keys) do
    for {k, v} <- map, into: %{}, do: {Map.get(keys, k, k), v}
  end
end
