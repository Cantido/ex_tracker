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
    first_peer = TestUtils.peer_one_map()
    second_peer = TestUtils.peer_two_map()

    first_request = TestUtils.request(first_peer)
    second_request = TestUtils.request(second_peer)

    Extracker.request first_request
    second_response = Extracker.request second_request

    assert first_peer.peer_id in TestUtils.peer_ids(second_response)
    assert second_peer.peer_id in TestUtils.peer_ids(second_response)
  end

  test "peers of other torrents are not returned" do
    first_peer = TestUtils.peer_one_map()
    second_peer = TestUtils.peer_two_map()

    first_request = %{TestUtils.request(first_peer) | info_hash: <<5>>}
    second_request = %{TestUtils.request(second_peer) | info_hash: <<12>>}

    Extracker.request first_request
    second_response = Extracker.request second_request

    refute first_peer.peer_id in TestUtils.peer_ids(second_response)
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
