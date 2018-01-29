alias ExtrackerServer.{Torrent, Peer}

defmodule ExtrackerServer.TorrentTest do
  use ExUnit.Case
  doctest ExtrackerServer.Torrent

  test "drop old peers" do
    max_age = 5
    current_time = 21
    old_age = 10
    young_age = 20

    old_peer = Peer.new(<<0>>, old_age)
    new_peer = Peer.new(<<1>>, young_age)

    torrent1 = Torrent.new([old_peer, new_peer])
           |> Torrent.drop_old_peers(max_age, current_time)

    assert {:ok, new_peer} == Torrent.fetch_peer(torrent1, <<1>>)
    assert :error == Torrent.fetch_peer(torrent1, <<0>>)
  end

  test "knows its size" do
    peer1 = Peer.new(<<0>>, 10)
    peer2 = Peer.new(<<1>>, 20)

    torrent = Torrent.new([peer1])
    assert Torrent.size(torrent) == 1

    torrent1 = Torrent.add_peer torrent, peer2
    assert Torrent.size(torrent1) == 2
  end

  test "fetch peer by ID" do
    peer = Peer.new(<<0>>, 10)

    torrent = Torrent.new([peer])

    assert Torrent.fetch_peer(torrent, <<0>>) == {:ok, peer}
  end

  test "fetch a peer that doesn't exist" do
    torrent = Torrent.new()

    assert Torrent.fetch_peer(torrent, <<0>>) == :error
  end

  test "keyed by peer_id" do
    peer = Peer.new(<<0>>, 10)
    peer1 = Peer.new(<<0>>, 20)

    torrent = Torrent.new([peer]) |> Torrent.add_peer(peer1)

    assert Torrent.size(torrent) == 1
  end
end
