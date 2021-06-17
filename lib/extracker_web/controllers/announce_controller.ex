defmodule ExtrackerWeb.AnnounceController do
  use ExtrackerWeb, :controller

  def index(conn, %{
    "info_hash" => info_hash,
    "peer_id" => peer_id,
    "port" => port,
    "uploaded" => uploaded,
    "downloaded" => downloaded,
    "left" => left
  } = params) do
    event =
      case Map.get(params, "event", "") do
        "started" -> :started
        "stopped" -> :stopped
        "completed" -> :completed
        _ -> :interval
      end

    ip =
      if Map.has_key?(params, "ip") do
        {:ok, iptuple} = :inet.parse_address(String.to_charlist(params["ip"]))
        iptuple
      else
        conn.remote_ip
      end

    address = {ip, String.to_integer(port)}
    progress = {String.to_integer(uploaded), String.to_integer(downloaded), String.to_integer(left)}

    announce_result = Extracker.announce(
      info_hash,
      peer_id,
      address,
      progress,
      event: event
    )

    with {:ok, response} <- announce_result,
         format_type = format_type(conn),
         response_body = Extracker.Format.format(response, format_type) do
      bencode(conn, response_body)
    end
  end


  defp format_type(conn) do
    if compact_peers?(conn), do: :compact, else: :standard
  end

  defp compact_peers?(conn) do
    conn.query_params["compact"] == "1"
  end
end
