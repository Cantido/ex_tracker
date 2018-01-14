alias Extracker.TorrentRegistry

defmodule ExtrackerTest do
  use ExUnit.Case
  doctest Extracker

  setup do
    Extracker.set_interval 9_000
  end

  test "valid request turns a map of data" do
    response = Extracker.request TestUtils.request()

    assert response.interval == 9_000
    assert response.peers != nil
  end

  test "register and retrieve a peer" do
    state = tracker_with_peer(<<0>>, TestUtils.peer_one_map())
    request = TestUtils.request(TestUtils.peer_two_map())

    {:reply, reply, state1} = Extracker.handle_call({:announce, request}, {}, state)

    assert length(reply.peers) == 2
    assert TorrentRegistry.size(state1.registry) == 1

    peers = TorrentRegistry.lookup(state1.registry, <<0>>).peers
    assert MapSet.size(peers) == 2
  end

  defp tracker_with_peer(info_hash, peer) do
    %Extracker{
      registry: TorrentRegistry.new()
        |> TorrentRegistry.add_peer_to_torrent(info_hash, peer)
    }
  end

  test "peers of other torrents are not returned" do
    state = tracker_with_peer(<<0>>, TestUtils.peer_one_map())
    request = %{TestUtils.request() | info_hash: <<12>>}

    {:reply, reply, state1} = Extracker.handle_call({:announce, request}, {}, state)

    assert length(reply.peers) == 1
    assert TorrentRegistry.size(state1.registry) == 2

    peers = TorrentRegistry.lookup(state1.registry, <<0>>).peers
    assert MapSet.size(peers) == 1

    peers2 = TorrentRegistry.lookup(state1.registry, <<12>>).peers
    assert MapSet.size(peers2) == 1
  end

  test "peers expire" do
    Extracker.set_interval(0) # all peers expire immediately
    Extracker.set_cleanup_interval(100)

    first_peer = TestUtils.peer_one_map()
    first_request = %{TestUtils.request(first_peer) | info_hash: <<5>>}
    Extracker.request first_request

    Process.sleep(300)

    second_peer = TestUtils.peer_two_map()
    second_request = %{TestUtils.request(second_peer) | info_hash: <<5>>}
    second_response = Extracker.request second_request

    refute first_peer.peer_id in TestUtils.peer_ids(second_response)
  end

  test "info_hash is required" do
    malformed_request = Map.delete(TestUtils.request(), :info_hash)
    response = Extracker.request malformed_request

    assert response == %{failure_reason: "invalid request"}
  end

  test "peer ID is required" do
    malformed_request = Map.delete(TestUtils.request(), :peer_id)
    response = Extracker.request malformed_request

    assert response == %{failure_reason: "invalid request"}
  end

  test "port number is required" do
    malformed_request = Map.delete(TestUtils.request(), :port)
    response = Extracker.request malformed_request

    assert response == %{failure_reason: "invalid request"}
  end

  test "uploaded is required" do
    malformed_request = Map.delete(TestUtils.request(), :uploaded)
    response = Extracker.request malformed_request

    assert response == %{failure_reason: "invalid request"}
  end

  test "downloaded is required" do
    malformed_request = Map.delete(TestUtils.request(), :downloaded)
    response = Extracker.request malformed_request

    assert response == %{failure_reason: "invalid request"}
  end

  test "left is required" do
    malformed_request = Map.delete(TestUtils.request(), :left)
    response = Extracker.request malformed_request

    assert response == %{failure_reason: "invalid request"}
  end

  test "ip is required" do
    malformed_request = Map.delete(TestUtils.request(), :ip)
    response = Extracker.request malformed_request

    assert response == %{failure_reason: "invalid request"}
  end
end
