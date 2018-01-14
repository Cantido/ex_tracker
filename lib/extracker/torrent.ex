alias Extracker.Peer

defmodule Extracker.Torrent do
  @moduledoc """
  Functions for manipulating tracked torrents.
  """

  defstruct peers: MapSet.new

  @doc """
  Create a new torrent with no peers.
  """
  def new do
    %Extracker.Torrent{}
  end

  @doc """
  Create a new torrent that is tracking the given `peers`.
  """
  def new(peers) when is_list(peers) do
    %Extracker.Torrent{peers: MapSet.new(peers)}
  end

  @doc """
  Add a `peer` to a `torrent`'s list of tracked peers.
  """
  def add_peer(torrent, peer) do
    %{torrent | peers: MapSet.put(torrent.peers, peer)}
  end

  @doc """
  Drop all tracked peers from `torrent` that are older than `max_age`.

  It is recommended to use `System.monotonic_time(:seconds)` to fetch
  the current time. That value is much more stable and useful for
  age comparisons. Be careful that the time unit of `max_age` is the same
  as the unit of `current_time`.
  """
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
