alias Extracker.Peer

defmodule Extracker.Torrent do
  @moduledoc """
  Functions for manipulating tracked torrents.
  """

  defstruct peers: Map.new

  @doc """
  Create a new torrent with no peers.

  ## Examples

      iex> torrent = Extracker.Torrent.new()
      iex> Enum.to_list(torrent.peers)
      []
  """
  def new do
    %Extracker.Torrent{}
  end

  @doc """
  """
  def new(peers) when is_list(peers) do
    %Extracker.Torrent{peers: Map.new(peers, fn(x) -> {x.peer_id, x} end)}
  end

  def size(torrent) do
    map_size(torrent.peers)
  end

  @doc """
  Add a `peer` to a `torrent`'s list of tracked peers.
  """
  def add_peer(torrent, peer) do

    peers1 = Map.put(torrent.peers, peer.peer_id, peer)

    %{torrent | peers: peers1}
  end

  def fetch_peer(torrent, peer_id) do
    Map.fetch(torrent.peers, peer_id)
  end

  @doc """
  Drop all tracked peers from `torrent` that are older than `max_age`.

  It is recommended to use `System.monotonic_time(:seconds)` to fetch
  the current time. That value is much more stable and useful for
  age comparisons. Be careful that the time unit of `max_age` is the same
  as the unit of `current_time`.
  """
  def drop_old_peers(torrent, max_age, current_time) do
    too_old_filter = fn({_id, x}) -> Peer.too_old?(x, max_age, current_time) end

    reject_peers(torrent, too_old_filter)
  end

  defp reject_peers(torrent, fun) do
    %{torrent | peers: reject_peers_mapset(torrent.peers, fun) }
  end

  defp reject_peers_mapset(peers, fun) do
    Enum.reject(peers, fun) |> Map.new()
  end
end
