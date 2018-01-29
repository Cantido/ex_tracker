alias ExtrackerServer.{TorrentRegistry, Torrent}
import ExtrackerServer.TestHelper

defmodule ExtrackerServerTest do
  use ExUnit.Case
  doctest ExtrackerServer

  @interval_s 9_001

  setup do
    ExtrackerServer.set_interval @interval_s
  end

  test "valid request turns a map of data" do
    response = ExtrackerServer.request request()

    assert response.interval_s == @interval_s
    assert is_list response.peers
  end

  test "register and retrieve a peer" do
    state = tracker_with_peer(<<0>>, peer_one_map())
    request = request(peer_two_map())

    {:reply, reply, state1} = ExtrackerServer.handle_call({:announce, request}, {}, state)

    assert length(reply.peers) == 2
    assert TorrentRegistry.size(state1.registry) == 1

    torrent = TorrentRegistry.lookup(state1.registry, <<0>>)
    assert Torrent.size(torrent) == 2
  end

  test "peers are stripped of unused data" do
    request = request()

    {:reply, reply, _} = ExtrackerServer.handle_call({:announce, request}, {}, ExtrackerServer.new())

    assert [peer | _] = reply.peers
    assert Map.keys(peer) == [:ip, :peer_id, :port]
  end

  defp tracker_with_peer(info_hash, peer) do
    %ExtrackerServer{
      registry: registry_with_peer(info_hash, peer)
    }
  end

  defp registry_with_peer(info_hash, peer) do
    TorrentRegistry.new()
      |> TorrentRegistry.add_peer_to_torrent(info_hash, peer)
  end

  test "peers of other torrents are not returned" do
    state = tracker_with_peer(<<0>>, peer_one_map())
    request = %{request() | info_hash: <<12>>}

    {:reply, reply, state1} = ExtrackerServer.handle_call({:announce, request}, {}, state)

    assert length(reply.peers) == 1
    assert TorrentRegistry.size(state1.registry) == 2

    torrent = TorrentRegistry.lookup(state1.registry, <<0>>)
    assert Torrent.size(torrent) == 1

    torrent = TorrentRegistry.lookup(state1.registry, <<12>>)
    assert Torrent.size(torrent) == 1
  end

  test "peers expire" do
    ExtrackerServer.set_interval(0) # all peers expire immediately
    ExtrackerServer.set_cleanup_interval(100)

    first_peer = peer_one_map()
    first_request = %{request(first_peer) | info_hash: <<5>>}
    ExtrackerServer.request first_request

    Process.sleep(300)

    second_peer = peer_two_map()
    second_request = %{request(second_peer) | info_hash: <<5>>}
    second_response = ExtrackerServer.request second_request

    refute first_peer.peer_id in peer_ids(second_response)
  end

  test "info_hash is required", do: assert_key_required(:info_hash)
  test "peer ID is required", do: assert_key_required(:peer_id)
  test "port number is required", do: assert_key_required(:port)
  test "uploaded is required", do: assert_key_required(:uploaded)
  test "downloaded is required", do: assert_key_required(:downloaded)
  test "left is required", do: assert_key_required(:left)
  test "ip is required", do: assert_key_required(:ip)

  defp assert_key_required(key) do
    assert request_with_missing(key) == %{failure_reason: "invalid request"}
  end

  defp request_with_missing(key) do
    malformed_request = Map.delete(ExtrackerServer.TestHelper.request(), key)
    ExtrackerServer.request malformed_request
  end
end
