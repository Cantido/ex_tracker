alias Extracker.Peer

defmodule Extracker.Torrent do
  defstruct peers: MapSet.new

  def new do
    %Extracker.Torrent{}
  end

  def new(peers) when is_list(peers) do
    %Extracker.Torrent{peers: MapSet.new(peers)}
  end

  def add_peer(torrent, peer) do
    %{torrent | peers: MapSet.put(torrent.peers, peer)}
  end

  def drop_old_peers(torrent, max_age, current_time) do
    too_old_filter = &Peer.too_old?(&1, max_age, current_time)

    reject_peers(torrent, too_old_filter)
  end

  defp reject_peers(torrent, fun) do
    %{torrent | peers: reject_peers_mapset(torrent.peers, fun) }
  end

  defp reject_peers_mapset(peers, fun) do
    Enum.reject(peers, fun) |> MapSet.new()
  end
end
