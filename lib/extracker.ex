# SPDX-FileCopyrightText: 2021 Rosa Richter
#
# SPDX-License-Identifier: MIT

defmodule Extracker do
  @moduledoc """
  A fast & scaleable BitTorrent tracker.
  """

  defguardp is_ip_address(a, b, c, d) when a in 0..255 and b in 0..255 and c in 0..255 and d in 0..255
  defguardp is_ip_port(port) when port in 0..65_535
  defguardp is_info_hash(hash) when is_binary(hash) and byte_size(hash) == 20

  def set_interval(interval) do
    Redix.command!(:redix, ["SET", "interval", interval])
    :ok
  end

  @doc """
  Announce a peer to the tracker.
  """
  def announce(info_hash, peer_id, address, stats, opts \\ [])

  def announce(
    hash,
    id,
    {{a, b, c, d}, port},
    {ul, dl, left},
    opts
  )
  when is_info_hash(hash)
   and is_binary(id) and byte_size(id) == 20
   and is_ip_port(port)
   and ul >= 0 and dl >= 0 and left >= 0
   and is_ip_address(a, b, c, d) do
    event = Keyword.get(opts, :event, :interval)
    numwant = Keyword.get(opts, :numwant, 50)

    peer_id = Base.encode16(id, case: :lower)
    info_hash = Base.encode16(hash, case: :lower)

    now_iso8601 = DateTime.utc_now() |> DateTime.to_iso8601()

    config_queries = [
      ["GET", "interval"]
    ]

    peer_data_queries = [
      ["SET", "peer:#{peer_id}:address", "#{:inet.ntoa({a, b, c, d})}:#{port}"],
      ["SET", "peer:#{peer_id}:last_contacted", now_iso8601]
    ]

    peer_state_queries =
      case event do
        :interval -> []
        :completed -> [
          ["INCR", "torrent:#{info_hash}:downloaded"],
          ["SADD", "torrent:#{info_hash}:complete-peers", peer_id],
          ["SREM", "torrent:#{info_hash}:incomplete-peers", peer_id],
          ["SUNIONSTORE", "torrent:#{info_hash}:peers", "torrent:#{info_hash}:incomplete-peers", "torrent:#{info_hash}:complete-peers"],
        ]
        :started -> [
          ["SADD", "torrent:#{info_hash}:incomplete-peers", peer_id],
          ["SREM", "torrent:#{info_hash}:complete-peers", peer_id],
          ["SUNIONSTORE", "torrent:#{info_hash}:peers", "torrent:#{info_hash}:incomplete-peers", "torrent:#{info_hash}:complete-peers"],
        ]
        :stopped -> [
          ["SREM", "torrent:#{info_hash}:complete-peers", peer_id],
          ["SREM", "torrent:#{info_hash}:incomplete-peers", peer_id],
          ["SUNIONSTORE", "torrent:#{info_hash}:peers", "torrent:#{info_hash}:incomplete-peers", "torrent:#{info_hash}:complete-peers"],
        ]
      end

    peer_list_queries =
      [
        ["SCARD", "torrent:#{info_hash}:complete-peers"],
        ["SCARD", "torrent:#{info_hash}:incomplete-peers"],
        ["SRANDMEMBER", "torrent:#{info_hash}:peers", numwant]
      ]

    redis_results =
      Redix.pipeline!(:redix, config_queries ++ peer_data_queries ++ peer_state_queries ++ peer_list_queries)

    ids = List.last(redis_results)

    address_requests =
      Enum.map(ids, fn id_i ->
        ["GET", "peer:#{id_i}:address"]
      end)

    addresses =
      if Enum.empty?(address_requests) do
        []
      else
        Redix.pipeline!(:redix, address_requests)
      end

    peers = Enum.zip(ids, addresses)
      |> Enum.map(fn {id, address} ->
        [host_str, port_str] = String.split(address, ":", limit: 2)

        {:ok, ip} = :inet.parse_address(String.to_charlist(host_str))
        port = String.to_integer(port_str)
        %{
          peer_id: Base.decode16!(id, case: :lower),
          ip: ip,
          port: port
        }
      end)

    interval = List.first(redis_results) |> String.to_integer()
    complete_count = Enum.at(redis_results, -3)
    incomplete_count = Enum.at(redis_results, -2)

    {:ok, %{complete: complete_count, incomplete: incomplete_count, interval: interval, peers: peers}}
  end

  def announce(_, _, _, _, _) do
    {:error, "invalid request" }
  end

  def scrape(info_hash) when is_info_hash(info_hash) do
    info_hash = Base.encode16(info_hash, case: :lower)

    results =
    Redix.pipeline!(:redix, [
      ["SCARD", "torrent:#{info_hash}:complete-peers"],
      ["SCARD", "torrent:#{info_hash}:incomplete-peers"],
      ["GET", "torrent:#{info_hash}:downloaded"]
    ])

    downloaded =
      if dl = Enum.at(results, 2) do
        String.to_integer(dl)
      else
        0
      end


    {:ok, %{
      complete: Enum.at(results, 0),
      incomplete: Enum.at(results, 1),
      downloaded: downloaded
    }}
  end

  def scrape(_req) do
    {:error, :invalid_info_hash}
  end

  def drop(info_hash) do

  end

  def count_torrents do
    :telemetry.execute([:extracker, :torrents], %{count: 0})
  end

  def count_peers do
    :telemetry.execute([:extracker, :peers], %{count: 0})
  end
end
