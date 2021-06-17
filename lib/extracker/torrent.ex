defmodule Extracker.Torrent do
  @moduledoc """
  Functions for manipulating tracked torrents.
  """

  alias Extracker.Peer

  defstruct [
    downloaded_count: 0,
    peers: Map.new()
  ]

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

  def peers(%__MODULE__{peers: peers}) do
    Map.values(peers)
  end

  @doc """
  Add a `peer` to a `torrent`'s list of tracked peers.
  """
  def add_peer(torrent, peer_id, ip, port) do
    peers = Map.put_new(torrent.peers, peer_id, Peer.new(peer_id, ip, port))

    %{torrent | peers: peers}
  end

  def peer_announced(torrent, peer_id, timestamp) do
    peers = Map.update!(torrent.peers, peer_id, &Peer.announced(&1, timestamp))

    %{torrent | peers: peers}
  end

  def drop_old_peers(torrent, current_time, max_age, unit \\ :second) do
    peers =
      Enum.reject(torrent.peers, fn({_id, x}) -> Peer.age(x, current_time, unit) > max_age end)
      |> Map.new()

    %{torrent | peers: peers}
  end

  def count_downloaded(torrent) do
    torrent.downloaded_count
  end

  def count_incomplete(torrent) do
    Enum.count(
      torrent.peers,
      fn({_, peer}) -> Peer.incomplete?(peer) end
    )
  end

  def count_complete(torrent) do
    Enum.count(
      torrent.peers,
      fn({_, peer}) -> Peer.complete?(peer) end
    )
  end

  def peer_completed(torrent, peer_id) do
    updated_peer = torrent.peers[peer_id] |> Peer.completed()
    new_peers = Map.put(torrent.peers, peer_id, updated_peer)
    %{torrent | peers: new_peers, downloaded_count: torrent.downloaded_count + 1}
  end

  def peer_stopped(torrent, peer_id) do
    %{torrent | peers: Map.drop(torrent.peers, [peer_id])}
  end
end
