defmodule ExtrackerTest do
  use ExUnit.Case
  doctest Extracker

  def valid_request do
    %{
      info_hash: 0,
      peer_id: 0,
      port: 0,
      uploaded: 0,
      downloaded: 0,
      left: 0,
      ip: 0
    }
  end

  test "valid request turns a map of data" do
    response = Extracker.request valid_request()

    assert response.interval == 9_000
    assert response.peers != nil
  end

  test "register and retrieve a peer" do
    first_peer = %{
      peer_id: 1,
      ip: {127, 0, 0, 1},
      port: 8001
    }

    second_peer = %{
      peer_id: 2,
      ip: {10, 0, 0, 1},
      port: 8002
    }

    first_request = %{
      info_hash: 0,
      peer_id: first_peer.peer_id,
      port: first_peer.port,
      ip: first_peer.ip,
      uploaded: 0,
      downloaded: 0,
      left: 0
    }

    second_request = %{
      info_hash: 0,
      peer_id: second_peer.peer_id,
      port: second_peer.port,
      ip: second_peer.ip,
      uploaded: 0,
      downloaded: 0,
      left: 0
    }

    Extracker.request first_request
    second_response = Extracker.request second_request

    assert first_peer in second_response.peers
    assert second_peer in second_response.peers
  end

  test "info_hash is required" do
    malformed_request = Map.delete(valid_request(), :info_hash)
    response = Extracker.request malformed_request

    assert response == %{failure_reason: "invalid request"}
  end

  test "peer ID is required" do
    malformed_request = Map.delete(valid_request(), :peer_id)
    response = Extracker.request malformed_request

    assert response == %{failure_reason: "invalid request"}
  end

  test "port number is required" do
    malformed_request = Map.delete(valid_request(), :port)
    response = Extracker.request malformed_request

    assert response == %{failure_reason: "invalid request"}
  end

  test "uploaded is required" do
    malformed_request = Map.delete(valid_request(), :uploaded)
    response = Extracker.request malformed_request

    assert response == %{failure_reason: "invalid request"}
  end

  test "downloaded is required" do
    malformed_request = Map.delete(valid_request(), :downloaded)
    response = Extracker.request malformed_request

    assert response == %{failure_reason: "invalid request"}
  end

  test "left is required" do
    malformed_request = Map.delete(valid_request(), :left)
    response = Extracker.request malformed_request

    assert response == %{failure_reason: "invalid request"}
  end

  test "ip is required" do
    malformed_request = Map.delete(valid_request(), :ip)
    response = Extracker.request malformed_request

    assert response == %{failure_reason: "invalid request"}
  end
end
