alias Extracker.Peer

defmodule Extracker.PeerTest do
  use ExUnit.Case
  doctest Extracker.Peer

  @peer_id <<0>>

  test "age" do
    current_time = 10
    peer = %Peer{
      peer_id: @peer_id,
      last_announce: 5
    }

    assert Peer.age(peer, current_time) == 5
  end

  test "too old" do
    max_age = 10
    current_time = 1000
    last_announce = 50

    peer = %{
      peer_id: @peer_id,
      last_announce: last_announce
    }

    assert Extracker.Peer.too_old?(peer, max_age, current_time)
  end
end
