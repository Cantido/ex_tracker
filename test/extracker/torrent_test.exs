alias Extracker.{Torrent, Peer}

defmodule Extracker.TorrentTest do
  use ExUnit.Case
  doctest Extracker.Torrent

  test "drop old peers" do
    old_peer = Peer.new(<<0>>, 10)
    new_peer = Peer.new(<<1>>, 20)

    torrent = Torrent.new([old_peer, new_peer])

    max_age = 5
    current_time = 21

    torrent1 = Torrent.drop_old_peers(torrent, max_age, current_time)

    assert new_peer in torrent1.peers
    refute old_peer in torrent1.peers

  end
end
