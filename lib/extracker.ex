defmodule Extracker do
  use Agent

  def start_link(_) do
    start_link()
  end

  def start_link do
    Agent.start_link(fn -> MapSet.new end, name: __MODULE__)
  end

  def request(%{info_hash: _, peer_id: _, port: _, uploaded: _, downloaded: _, left: _, ip: _} = req) do
    peer = Map.take(req, [:peer_id, :ip, :port])
    peers = Agent.get_and_update(__MODULE__, &put_and_return(&1, peer))
    %{
      interval: 9_000,
      peers: MapSet.to_list(peers)
    }
  end

  def request(_req) do
    %{ failure_reason: "invalid request" }
  end

  defp put_and_return(set, elem) do
    updated = MapSet.put(set, elem)
    {updated, updated}
  end
end
