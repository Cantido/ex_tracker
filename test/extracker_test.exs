# SPDX-FileCopyrightText: 2021 Rosa Richter
#
# SPDX-License-Identifier: MIT

defmodule ExtrackerTest do
  use ExUnit.Case, async: true
  doctest Extracker

  setup_all do
    Extracker.set_interval(120)
  end

  describe "announce" do
    test "remembers peers that announce" do
      info_hash = :crypto.strong_rand_bytes(20)
      on_exit(fn ->
        Extracker.drop(info_hash)
      end)

      peer_id_1 = :crypto.strong_rand_bytes(20)
      peer_id_2 = :crypto.strong_rand_bytes(20)

      {:ok, _resp} = Extracker.announce(
        info_hash,
        peer_id_1,
        {{127, 0, 0, 1}, 8000},
        {0, 0, 0},
        event: :started
      )

      {:ok, resp} =
        Extracker.announce(
          info_hash,
          peer_id_2,
          {{127, 0, 0, 1}, 8001},
          {0, 0, 0},
          event: :started
        )

      assert is_number(resp.interval)
      assert resp.interval > 0

      assert resp.complete == 0
      assert resp.incomplete == 2

      assert Enum.count(resp.peers) == 2
      peer_1 = Enum.find(resp.peers, & &1.peer_id == peer_id_1)
      assert peer_1.ip == {127, 0, 0, 1}
      assert peer_1.port == 8000


      peer_2 = Enum.find(resp.peers, & &1.peer_id == peer_id_2)
      assert peer_2.ip == {127, 0, 0, 1}
      assert peer_2.port == 8001
    end

    test "remembers when peers complete" do
      info_hash = :crypto.strong_rand_bytes(20)
      on_exit(fn ->
        Extracker.drop(info_hash)
      end)

      peer_id_1 = :crypto.strong_rand_bytes(20)
      peer_id_2 = :crypto.strong_rand_bytes(20)

      {:ok, _resp} = Extracker.announce(
        info_hash,
        peer_id_1,
        {{127, 0, 0, 1}, 8000},
        {0, 0, 100},
        event: :started
      )

      {:ok, _resp} = Extracker.announce(
        info_hash,
        peer_id_1,
        {{127, 0, 0, 1}, 8000},
        {0, 100, 0},
        event: :completed
      )

      {:ok, resp} =
        Extracker.announce(
          info_hash,
          peer_id_2,
          {{127, 0, 0, 1}, 8001},
          {0, 0, 0},
          event: :started
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

      {:ok, resp} = Extracker.scrape(info_hash)

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

      {:ok, resp} = Extracker.scrape(info_hash)

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

      {:ok, _resp} = Extracker.announce(
        info_hash,
        peer_id,
        {{127, 0, 0, 1}, 8000},
        {0, 100, 0},
        event: :completed
      )

      {:ok, _resp} = Extracker.announce(
        info_hash,
        peer_id,
        {{127, 0, 0, 1}, 8000},
        {0, 0, 0},
        event: :stopped
      )

      {:ok, resp} = Extracker.scrape(info_hash)

      assert resp.complete == 0
      assert resp.downloaded == 1
      assert resp.incomplete == 0
    end
  end

  describe "drop/1" do
    test "drops all peers" do
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

      :ok = Extracker.drop(info_hash)

      {:ok, resp} = Extracker.scrape(info_hash)

      assert resp.complete == 0
      assert resp.downloaded == 0
      assert resp.incomplete == 0
    end
  end
end
