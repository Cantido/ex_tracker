alias Extracker.{Swarm, Torrent}
import Extracker.TestHelper

defmodule ExtrackerTest do
  use ExUnit.Case
  doctest Extracker

  @interval_s 9_001

  setup do
    Extracker.set_interval @interval_s
  end

  test "valid request turns a map of data" do
    response = %{interval_s: @interval_s, peers: peers} = Extracker.request request()

    assert response.interval_s == @interval_s
    assert is_list peers
  end

  test "register and retrieve a peer" do
    state = tracker_with_peer("Existing Torrent ID-", peer_one_map())
    request = request("Existing Torrent ID-", peer_two_map())

    {:reply, reply, state1} = Extracker.handle_call({:announce, request}, {}, state)

    assert length(reply.peers) == 2
    assert Swarm.size(state1.registry) == 1

    torrent = Swarm.lookup(state1.registry, "Existing Torrent ID-")
    assert Torrent.size(torrent) == 2
  end

  test "peers are stripped of unused data" do
    request = request()

    {:reply, reply, _} = Extracker.handle_call({:announce, request}, {}, Extracker.new())

    assert [peer | _] = reply.peers
    assert Map.keys(peer) == [:ip, :peer_id, :port]
  end

  defp tracker_with_peer(info_hash, peer) do
    %Extracker{
      registry: registry_with_peer(info_hash, peer)
    }
  end

  defp registry_with_peer(info_hash, peer) do
    Swarm.new()
      |> Swarm.add_peer_to_torrent(info_hash, peer)
  end

  test "peers of other torrents are not returned" do
    state = tracker_with_peer("Existing Torrent ID-", peer_one_map())

    request = %{request() | info_hash: "New Torrent ID------"}
    {:reply, reply, state1} = Extracker.handle_call({:announce, request}, {}, state)

    assert length(reply.peers) == 1
    assert Swarm.size(state1.registry) == 2

    torrent = Swarm.lookup(state1.registry, "Existing Torrent ID-")
    assert Torrent.size(torrent) == 1

    torrent = Swarm.lookup(state1.registry, "New Torrent ID------")
    assert Torrent.size(torrent) == 1
  end

  test "peers expire" do
    Extracker.set_interval(0) # all peers expire immediately
    Extracker.set_cleanup_interval(100)

    first_peer = peer_one_map()
    first_request = request(first_peer)
    Extracker.request first_request

    Process.sleep(300)

    second_peer = peer_two_map()
    second_request = request(second_peer)
    second_response = Extracker.request second_request

    refute first_peer.peer_id in peer_ids(second_response)
  end

  test "scrape counts peers" do
    scraped_torrent = %{request() | info_hash: "Scraped Info Hash---"}

    incomplete_peer = scraped_torrent
    |> Map.put(:peer_id, "Incomplete peer-----")
    |> Map.put(:event, :started)

    complete_peer = scraped_torrent
    |> Map.put(:peer_id, "Complete peer-------")
    |> Map.put(:event, :completed)

    %{complete: 0, downloaded: 0, incomplete: 0} = Extracker.scrape "Scraped Info Hash---"
    Extracker.request incomplete_peer
    %{complete: 0, downloaded: 0, incomplete: 1} = Extracker.scrape "Scraped Info Hash---"
    Extracker.request complete_peer
    %{complete: 1, downloaded: 1, incomplete: 1} = Extracker.scrape "Scraped Info Hash---"
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
    malformed_request = Map.delete(Extracker.TestHelper.request(), key)
    Extracker.request malformed_request
  end
end
