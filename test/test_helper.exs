ExUnit.start()

defmodule TestUtils do
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
    %{request(peer) | ip: :inet_parse.ntoa(peer.ip)}
  end
end
