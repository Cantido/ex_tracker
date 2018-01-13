alias Extracker.Torrent

defmodule Extracker.TorrentRegistry do
  defstruct torrents: Map.new()

  def new do
    %Extracker.TorrentRegistry{}
  end

  def add_peer_to_torrent(registry, info_hash, peer) do
    torrents1 = Map.update(
      registry.torrents,
      info_hash,
      Torrent.new([peer]),
      &Torrent.add_peer(&1, peer)
    )
    %{registry | torrents: torrents1}
  end

  def lookup(registry, info_hash) do
    Map.get(registry.torrents, info_hash)
  end

  def clean_torrents(registry, max_age, current_time) when max_age >= 0 do
    clean_fun = &Extracker.Torrent.drop_old_peers(&1, max_age, current_time)

    map(registry, clean_fun)
  end

  def map(registry, fun) do
    torrents1 = Enum.map(registry.torrents, &map1(&1, fun)) |> Map.new()
    %{registry | torrents: torrents1}
  end

  defp map1({info_hash, torrent}, fun) do
    {info_hash, fun.(torrent)}
  end
end
