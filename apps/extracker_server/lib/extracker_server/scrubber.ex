defmodule ExtrackerServer.Scrubber do
  use Plug.Builder

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

  def scrub_params(conn, _opts) do
    {port, _rem} = Integer.parse(conn.query_params.port)
    Map.update(conn, :query_params, %{}, &Map.put(&1, :port, port))
  end

  def rename_query_params(conn, key_names) when is_map(key_names) do
    Map.update(conn, :query_params, %{}, &rename_keys(&1, key_names))
  end

  def rename_keys(map, keys) when is_map(map) and is_map(keys) do
    for {k, v} <- map, into: %{}, do: {Map.get(keys, k, k), v}
  end
end
