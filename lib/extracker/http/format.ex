defmodule Extracker.HTTP.Format do
  def format(body) do
    {:ok, %{body | peers: format_peers(body)}}
  end

  defp format_peers(result) do
    Enum.map(result.peers, &format_peer_ip/1)
  end

  defp format_peer_ip(%{ip: ip} = peer) do
    %{peer | :ip => to_string(:inet.ntoa(ip))}
  end
end
