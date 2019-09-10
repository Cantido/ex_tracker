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

    response_body = case announce_result do
      {:ok, response} ->
        format_type = if compact_peers?(conn), do: :compact, else: :standard
        Extracker.Format.format(response, format_type)
      {:error, reason} ->
        %{ "failure reason" => reason}
    end

    {:ok, encoded_body} =  ExBencode.encode(response_body)
    text(conn, encoded_body)
  end

  defp integer_parse!(s) do
    {i, ""} = Integer.parse(s)
    i
  end

  defp compact_peers?(conn) do
    conn.query_params["compact"] == "1"
  end
end
