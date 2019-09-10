alias Extracker.Torrent

defmodule Extracker.Swarm do
  @moduledoc """
  Store torrents and look them up by their info hash.
  """
  defstruct torrents: Map.new()

  @doc """
  Create a new swarm.

  ## Examples

      iex> Extracker.Swarm.new()
      %Extracker.Swarm{}
  """
  def new do
    %Extracker.Swarm{}
  end

  @doc """
  Track a peer downloading a given torrent.

  If the torrent identified by `info_hash` does not exist yet, then it will
  be created.

  ## Examples

      iex> swarm = Extracker.Swarm.new()
      iex> peer = Extracker.Peer.new(<<0>>)
      iex> info_hash = <<20>>
      iex> size(swarm.torrents)
      0
      iex> swarm1 = Extracker.Swarm.add_peer_to_torrent(swarm, info_hash, peer)
      iex> size(swarm1.torrents)
      1
      iex> another_peer = Extracker.Peer.new(<<1>>)
      iex> swarm2 = ExTracker.Swarm.add_peer_to_torrent(swarm, info_hash, another_peer)
      iex> size(swarm2.torrents)
      1
  """
  def add_peer_to_torrent(swarm, info_hash, peer) do
    torrents1 = Map.update(
      swarm.torrents,
      info_hash,
      Torrent.new([peer]),
      &Torrent.add_peer(&1, peer)
    )
    %{swarm | torrents: torrents1}
  end

  def size(swarm) do
    map_size(swarm.torrents)
  end

  @doc """
  Fetch a torrent from the `swarm` by its `info_hash`.

  If the torrent is not present in the `swarm`, then `nil` is returned.
  """
  def lookup(swarm, info_hash) do
    Map.get(swarm.torrents, info_hash)
  end

  @doc """
  Drop expired peers from all torrents.

  For all torrents in `swarm`, peers who are older than `max_age` under
  the given `current_time` will be removed.
  """
  def clean_torrents(swarm, max_age, current_time) when max_age >= 0 do
    clean_fun = &Extracker.Torrent.drop_old_peers(&1, max_age, current_time)

    map(swarm, clean_fun)
  end

  @doc """
  Invoke `fun` on every torrent in the `swarm`.
  """
  def map(swarm, fun) do
    torrents1 = Enum.map(swarm.torrents, &map1(&1, fun)) |> Map.new()
    %{swarm | torrents: torrents1}
  end

  defp map1({info_hash, torrent}, fun) do
    {info_hash, fun.(torrent)}
  end
end
