defmodule ExtrackerTest do
  use ExUnit.Case, async: true
  doctest Extracker

  describe "announce" do
    test "remembers peers that announce" do
      info_hash = :crypto.strong_rand_bytes(20)
      on_exit(fn ->
        Extracker.drop(info_hash)
      end)

      peer_id_1 = :crypto.strong_rand_bytes(20)
      peer_id_2 = :crypto.strong_rand_bytes(20)

      Extracker.announce(
        info_hash,
        peer_id_1,
        {{127, 0, 0, 1}, 8000},
        {0, 0, 0}
      )

      resp =
        Extracker.announce(
          info_hash,
          peer_id_2,
          {{127, 0, 0, 1}, 8001},
          {0, 0, 0}
        )

      assert is_number(resp.interval)
      assert resp.interval > 0

      assert resp.complete == 0
      assert resp.incomplete == 2

      assert Enum.count(resp.peers) == 1
      peer = Enum.at(resp.peers, 0)
      assert peer.peer_id == peer_id_1
      assert peer.ip == {127, 0, 0, 1}
      assert peer.port == 8000
    end

    test "remembers when peers complete" do
      info_hash = :crypto.strong_rand_bytes(20)
      on_exit(fn ->
        Extracker.drop(info_hash)
      end)

      peer_id_1 = :crypto.strong_rand_bytes(20)
      peer_id_2 = :crypto.strong_rand_bytes(20)

      Extracker.announce(
        info_hash,
        peer_id_1,
        {{127, 0, 0, 1}, 8000},
        {0, 0, 100},
        event: :started
      )

      Extracker.announce(
        info_hash,
        peer_id_1,
        {{127, 0, 0, 1}, 8000},
        {0, 100, 0},
        event: :completed
      )

      resp =
        Extracker.announce(
          info_hash,
          peer_id_2,
          {{127, 0, 0, 1}, 8001},
          {0, 0, 0}
        )

      assert is_number(resp.interval)
      assert resp.interval > 0

      assert resp.complete == 1
      assert resp.incomplete == 1
    end
  end

  describe "scrape" do
    test "returns completed downloads" do
      info_hash = :crypto.strong_rand_bytes(20)
      on_exit(fn ->
        Extracker.drop(info_hash)
      end)

      Extracker.announce(
        info_hash,
        :crypto.strong_rand_bytes(20),
        {{127, 0, 0, 1}, 8000},
        {0, 100, 0},
        event: :completed
      )

      resp = Extracker.scrape(info_hash)

      assert resp.complete == 1
      assert resp.downloaded == 1
      assert resp.incomplete == 0
    end

    test "returns incomplete downloads" do
      info_hash = :crypto.strong_rand_bytes(20)
      on_exit(fn ->
        Extracker.drop(info_hash)
      end)

      Extracker.announce(
        info_hash,
        :crypto.strong_rand_bytes(20),
        {{127, 0, 0, 1}, 8000},
        {0, 0, 0},
        event: :started
      )

      resp = Extracker.scrape(info_hash)

      assert resp.complete == 0
      assert resp.downloaded == 0
      assert resp.incomplete == 1
    end

    test "returns downloaded after a peer leaves the swarm" do
      info_hash = :crypto.strong_rand_bytes(20)
      on_exit(fn ->
        Extracker.drop(info_hash)
      end)

      peer_id = :crypto.strong_rand_bytes(20)

      Extracker.announce(
        info_hash,
        peer_id,
        {{127, 0, 0, 1}, 8000},
        {0, 100, 0},
        event: :completed
      )

      Extracker.announce(
        info_hash,
        peer_id,
        {{127, 0, 0, 1}, 8000},
        {0, 0, 0},
        event: :stopped
      )

      resp = Extracker.scrape(info_hash)

      assert resp.complete == 0
      assert resp.downloaded == 1
      assert resp.incomplete == 0
    end
  end
end
