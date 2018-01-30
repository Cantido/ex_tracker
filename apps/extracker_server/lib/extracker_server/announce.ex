defmodule ExtrackerServer.Announce do
  use Plug.Builder

  plug :fetch_query_params
  plug ExtrackerServer.Scrubber
  plug :query

  def query(conn, _opts) do
    body = conn.query_params
    |> Map.put_new(:ip, conn.remote_ip)
    |> Extracker.request()
    |> rename_keys(%{interval_s: :interval})

    format_type = if compact_peers?(conn), do: :compact, else: :standard
    formatted = ExtrackerServer.Format.format(body, format_type)

    {:ok, encoded} = formatted |> ExBencode.encode()

    conn
    |> resp(200, encoded)
    |> put_resp_content_type("text/plain")
    |> send_resp()
  end

  defp compact_peers?(conn) do
    conn.query_params["compact"] == "1"
  end

  defp rename_keys(map, keys) when is_map(map) and is_map(keys) do
    for {k, v} <- map, into: %{}, do: {Map.get(keys, k, k), v}
  end
end
