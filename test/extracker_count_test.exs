defmodule ExtrackerCountTest do
  use ExUnit.Case, async: false

  setup_all do
    Extracker.set_interval(120)
  end

  describe "count_torrents/0" do
    test "returns the current number of torrents we know about" do
      info_hash = :crypto.strong_rand_bytes(20)

      on_exit(fn ->
        Extracker.drop(info_hash)
      end)

      assert Extracker.count_torrents() == 0

      Extracker.announce(
        info_hash,
        :crypto.strong_rand_bytes(20),
        {{127, 0, 0, 1}, 8000},
        {0, 100, 0},
        event: :completed
      )

      assert Extracker.count_torrents() == 1

      :ok = Extracker.drop(info_hash)

      assert Extracker.count_torrents() == 0
    end
  end

  describe "count_peers/0" do
    test "returns the current number of peers we know about" do
      info_hash_1 = :crypto.strong_rand_bytes(20)
      info_hash_2 = :crypto.strong_rand_bytes(20)

      on_exit(fn ->
        Extracker.drop(info_hash_1)
        Extracker.drop(info_hash_2)
      end)

      assert Extracker.count_torrents() == 0

      Extracker.announce(
        info_hash_1,
        :crypto.strong_rand_bytes(20),
        {{127, 0, 0, 1}, 8000},
        {0, 100, 0},
        event: :completed
      )

      Extracker.announce(
        info_hash_2,
        :crypto.strong_rand_bytes(20),
        {{127, 0, 0, 1}, 8001},
        {0, 100, 100},
        event: :started
      )

      assert Extracker.count_peers() == 2

      :ok = Extracker.drop(info_hash_1)
      assert Extracker.count_peers() == 1

      :ok = Extracker.drop(info_hash_2)
      assert Extracker.count_peers() == 0
    end
  end
end
