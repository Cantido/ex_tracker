alias Extracker.Torrent

defmodule Extracker.TorrentRegistry do
  @moduledoc """
  Store torrents and look them up by their info hash.
  """
  defstruct torrents: Map.new()

  @doc """
  Create a new registry.

  ## Examples

      iex> Extracker.TorrentRegistry.new()
      %Extracker.TorrentRegistry{}
  """
  def new do
    %Extracker.TorrentRegistry{}
  end

  @doc """
  Track a peer downloading a given torrent.

  If the torrent identified by `info_hash` does not exist yet, then it will
  be created.

  ## Examples

      iex> registry = Extracker.TorrentRegistry.new()
      iex> peer = Extracker.Peer.new(<<0>>)
      iex> info_hash = <<20>>
      iex> size(registry.torrents)
      0
      iex> registry1 = Extracker.TorrentRegistry.add_peer_to_torrent(registry, info_hash, peer)
      iex> size(registry1.torrents)
      1
      iex> another_peer = Extracker.Peer.new(<<1>>)
      iex> registry2 = ExTracker.TorrentRegistry.add_peer_to_torrent(registry, info_hash, another_peer)
      iex> size(registry2.torrents)
      1
  """
  def add_peer_to_torrent(registry, info_hash, peer) do
    torrents1 = Map.update(
      registry.torrents,
      info_hash,
      Torrent.new([peer]),
      &Torrent.add_peer(&1, peer)
    )
    %{registry | torrents: torrents1}
  end

  @doc """
  Fetch a torrent from the `registry` by its `info_hash`.

  If the torrent is not present in the `registry`, then `nil` is returned.
  """
  def lookup(registry, info_hash) do
    Map.get(registry.torrents, info_hash)
  end

  @doc """
  Drop expired peers from all torrents.

  For all torrents in `registry`, peers who are older than `max_age` under
  the given `current_time` will be removed.
  """
  def clean_torrents(registry, max_age, current_time) when max_age >= 0 do
    clean_fun = &Extracker.Torrent.drop_old_peers(&1, max_age, current_time)

    map(registry, clean_fun)
  end

  @doc """
  Invoke `fun` on every torrent in the `registry`.
  """
  def map(registry, fun) do
    torrents1 = Enum.map(registry.torrents, &map1(&1, fun)) |> Map.new()
    %{registry | torrents: torrents1}
  end

  defp map1({info_hash, torrent}, fun) do
    {info_hash, fun.(torrent)}
  end
end
