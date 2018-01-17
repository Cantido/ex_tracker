defmodule Extracker.HTTP.Format do

  def format(%{compact: 1} = params, result) do
    peers = format_peers(params, result) |> Enum.join()
    {:ok, %{result | peers: peers}}
  end

  def format(params, result) do
    peers = format_peers(params, result)
    {:ok, %{result | peers: peers}}
  end

  def format_peers(params, result) do
    Enum.map(result.peers, &format_peer(params, &1))
  end

  def format_peer(%{compact: 1}, peer) do
    compact_peer(peer)
  end

  def format_peer(_params, peer) do
    format_peer_ip(peer)
  end

  @doc """
      iex>  Extracker.HTTP.Handler.format_peer(%{ip: {127, 0, 0, 1}, peer_id: <<1>>, port: 8001})
      %{ip: "127.0.0.1", peer_id: <<1>>, port: 8001}
  """
  def format_peer_ip(%{ip: ip} = peer) do
    %{peer | :ip => to_string(:inet.ntoa(ip))}
  end

  def compact_peer(%{peer_id: _, ip: {a, b, c, d}, port: port}) do
    <<a, b, c, d, port :: 16>>
  end
end
