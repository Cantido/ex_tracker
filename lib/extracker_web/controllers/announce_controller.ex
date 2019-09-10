defmodule ExtrackerWeb.AnnounceController do
  use ExtrackerWeb, :controller



  def index(conn, %{
    "info_hash" => info_hash,
    "peer_id" => peer_id,
    "ip" => ip,
    "port" => port,
    "downloaded" => downloaded,
    "left" => left
  } = params) do
    uploaded = Map.get(params, "uploaded", "0")
    event = Map.get(params, "event", "")

    {:ok, iptuple} = :inet.parse_address(String.to_charlist(ip))

    body = Extracker.announce(%{
      info_hash: info_hash,
      peer_id: peer_id,
      ip: iptuple,
      port: integer_parse!(port),
      uploaded: integer_parse!(uploaded),
      downloaded: integer_parse!(downloaded),
      left: integer_parse!(left),
      event: event
    })
    |> rename_keys(%{interval_s: :interval})

    if Map.has_key?(body, :failure_reason) do
      {:ok, encoded} = body |> ExBencode.encode()

      text(conn, encoded)
    else
      format_type = if compact_peers?(conn), do: :compact, else: :standard
      formatted = Extracker.Format.format(body, format_type)

      {:ok, encoded} = formatted |> ExBencode.encode()

      text(conn, encoded)
    end
  end

  defp integer_parse!(s) do
    {i, ""} = Integer.parse(s)
    i
  end

  defp compact_peers?(conn) do
    conn.query_params["compact"] == "1"
  end

  defp rename_keys(map, keys) when is_map(map) and is_map(keys) do
    for {k, v} <- map, into: %{}, do: {Map.get(keys, k, k), v}
  end
end
