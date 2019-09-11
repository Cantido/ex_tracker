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

    announce_result = Extracker.announce(%{
      info_hash: info_hash,
      peer_id: peer_id,
      ip: iptuple,
      port: integer_parse!(port),
      uploaded: integer_parse!(uploaded),
      downloaded: integer_parse!(downloaded),
      left: integer_parse!(left),
      event: event
    })

    with {:ok, response} <- announce_result,
         format_type = format_type(conn),
         response_body = Extracker.Format.format(response, format_type),
         {:ok, encoded_body} <- bencode(response_body) do
      text(conn, encoded_body)
    end
  end

  defp bencode(d) do
    case ExBencode.encode(d) do
      {:error, _} -> {:error, "internal server error"}
      success -> success
    end
  end

  defp format_type(conn) do
    if compact_peers?(conn), do: :compact, else: :standard
  end

  defp integer_parse!(s) do
    {i, ""} = Integer.parse(s)
    i
  end

  defp compact_peers?(conn) do
    conn.query_params["compact"] == "1"
  end
end
