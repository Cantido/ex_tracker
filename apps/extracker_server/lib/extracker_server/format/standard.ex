defmodule ExtrackerServer.Format.Standard do
  @behaviour ExtrackerServer.Format

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
end
