defmodule Extracker do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{peers: MapSet.new}, name: __MODULE__)
  end

  def request(%{info_hash: _, peer_id: _, port: _, uploaded: _, downloaded: _, left: _, ip: _} = req) do
    GenServer.call(__MODULE__, {:announce, req})
  end

  def request(_req) do
    %{ failure_reason: "invalid request" }
  end

  def handle_call({:announce, req}, _from, state) do
    peer = Map.take(req, [:peer_id, :ip, :port])
    peers = MapSet.put(state.peers, peer)
    {
      :reply,
      %{
        interval: 9_000,
        peers: MapSet.to_list(peers)
      },
      %{state | peers: peers}
    }
  end
end
