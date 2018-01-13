defmodule Extracker do
  use GenServer

  def start_link([interval]) do
    GenServer.start_link(__MODULE__, %{torrents: Map.new, interval: interval}, name: __MODULE__)
  end

  def request(%{info_hash: _, peer_id: _, port: _, uploaded: _, downloaded: _, left: _, ip: _} = req) do
    GenServer.call(__MODULE__, {:announce, req})
  end

  def request(_req) do
    %{ failure_reason: "invalid request" }
  end

  defp add_peer_to_torrent(torrents, info_hash, peer) do
    Map.update(
      torrents,
      info_hash,
      MapSet.new([peer]),
      &MapSet.put(&1, peer)
    )
  end

  def handle_call({:announce, %{info_hash: info_hash} = req}, _from, state) do
    peer = Map.take(req, [:peer_id, :ip, :port])

    torrents1 = add_peer_to_torrent(state.torrents, info_hash, peer)
    peers = Map.get(torrents1, info_hash)

    {
      :reply,
      %{
        interval: state.interval,
        peers: MapSet.to_list(peers)
      },
      %{state | torrents: torrents1}
    }
  end
end
