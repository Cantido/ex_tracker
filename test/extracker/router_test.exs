# SPDX-FileCopyrightText: 2021 Rosa Richter
#
# SPDX-License-Identifier: MIT

defmodule Extracker.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  setup_all do
    Extracker.set_interval(120)
  end

  describe "announce" do
    test "returns an empty response on the first announce" do
      info_hash = :crypto.strong_rand_bytes(20)
      on_exit(fn ->
        Extracker.drop(info_hash)
      end)

      params = %{
        info_hash: Base.encode16(info_hash, lower: true),
        peer_id: "12345678901234567890",
        port: 8001,
        uploaded: 0,
        downloaded: 0,
        left: 0,
        event: "started"
      }
      |> URI.encode_query(:rfc3986)

      conn = conn(:get, "/announce?" <> params)

      conn = Extracker.Router.call(conn, [])

      assert conn.state == :sent
      assert conn.status == 200

      body = Bento.decode!(conn.resp_body)

      assert body["complete"] == 0
      assert body["incomplete"] == 1
      assert body["interval"] == 120
    end
  end

  describe "scrape" do
    test "returns ok" do
      info_hash = :crypto.strong_rand_bytes(20)
      params = %{
        info_hash: Base.encode16(info_hash),
      }
      |> URI.encode_query(:rfc3986)

      conn = conn(:get, "/scrape?" <> params)

      conn = Extracker.Router.call(conn, [])

      assert conn.state == :sent
      assert conn.status == 200

      body = Bento.decode!(conn.resp_body)

      assert Map.has_key?(body, info_hash)
    end
  end
end
