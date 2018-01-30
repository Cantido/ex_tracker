ExUnit.start()

defmodule ExtrackerPlug.TestHelper do
  def peer do
    peer_one_map()
  end

  def peer_one_map do
    %{
      peer_id: <<1>>,
      ip: {127, 0, 0, 1},
      port: 8001
    }
  end

  def peer_two_map do
    %{
      peer_id: <<2>>,
      ip: {10, 0, 0, 1},
      port: 8002
    }
  end

  def request do
    request(peer_one_map())
  end

  def request(peer) do
    %{
      info_hash: <<0>>,
      peer_id: peer.peer_id,
      port: peer.port,
      ip: peer.ip,
      uploaded: 0,
      downloaded: 0,
      left: 0
    }
  end

  def request_query do
    request_query(peer_one_map())
  end

  def request_query(peer) do
    %{request(peer) | ip: "127.0.0.1"}
  end

  def peer_ids(response) do
    Enum.map(response.peers, &Map.get(&1, :peer_id))
  end

  def real_request do
    "info_hash=%d2%e5%3f%b6%03e-%99%19%91%b6%ad%23W%a7%a2%84ZS%19&peer_id=-TR2920-ytgm4shu94ut&port=51413&uploaded=0&downloaded=0&left=1899528192&numwant=0&key=73efbcef&compact=1&supportcrypto=1&event=stopped"
  end
end
