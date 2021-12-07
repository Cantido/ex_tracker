# SPDX-FileCopyrightText: 2021 Rosa Richter
#
# SPDX-License-Identifier: MIT

defmodule Extracker do
  @moduledoc """
  A fast & scaleable BitTorrent tracker.
  """

  @doc """
  Set the duration that an announced peer will be kept in the system.
  """
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
      ) do
    validate_info_hash!(hash)
    validate_peer_id!(id)
    validate_ip_address!({{a, b, c, d}, port})
    validate_byte_count!(ul)
    validate_byte_count!(dl)
    validate_byte_count!(left)

    event = Keyword.get(opts, :event, :interval)
    numwant = Keyword.get(opts, :numwant, 50)

    peer_id = Base.encode16(id, case: :lower)
    info_hash = Base.encode16(hash, case: :lower)

    now_iso8601 = DateTime.utc_now() |> DateTime.to_iso8601()

    config_queries = [
      ["GET", "interval"]
    ]

    peer_data_queries = [
      ["SADD", "torrents", info_hash],
      ["SET", "peer:#{peer_id}:address", "#{:inet.ntoa({a, b, c, d})}:#{port}"],
      ["SET", "peer:#{peer_id}:last_contacted", now_iso8601]
    ]

    peer_state_queries =
      case event do
        :interval ->
          []

        :completed ->
          [
            ["INCR", "torrent:#{info_hash}:downloaded"],
            ["SADD", "torrent:#{info_hash}:complete-peers", peer_id],
            ["SREM", "torrent:#{info_hash}:incomplete-peers", peer_id],
            [
              "SUNIONSTORE",
              "torrent:#{info_hash}:peers",
              "torrent:#{info_hash}:incomplete-peers",
              "torrent:#{info_hash}:complete-peers"
            ]
          ]

        :started ->
          [
            ["SADD", "torrent:#{info_hash}:incomplete-peers", peer_id],
            ["SREM", "torrent:#{info_hash}:complete-peers", peer_id],
            [
              "SUNIONSTORE",
              "torrent:#{info_hash}:peers",
              "torrent:#{info_hash}:incomplete-peers",
              "torrent:#{info_hash}:complete-peers"
            ]
          ]

        :stopped ->
          [
            ["SREM", "torrent:#{info_hash}:complete-peers", peer_id],
            ["SREM", "torrent:#{info_hash}:incomplete-peers", peer_id],
            [
              "SUNIONSTORE",
              "torrent:#{info_hash}:peers",
              "torrent:#{info_hash}:incomplete-peers",
              "torrent:#{info_hash}:complete-peers"
            ]
          ]
      end

    peer_list_queries = [
      ["SCARD", "torrent:#{info_hash}:complete-peers"],
      ["SCARD", "torrent:#{info_hash}:incomplete-peers"],
      ["SRANDMEMBER", "torrent:#{info_hash}:peers", numwant]
    ]

    redis_results =
      Redix.pipeline!(
        :redix,
        config_queries ++ peer_data_queries ++ peer_state_queries ++ peer_list_queries
      )

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

    peers =
      Enum.zip(ids, addresses)
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

    {:ok,
     %{complete: complete_count, incomplete: incomplete_count, interval: interval, peers: peers}}
  end

  def announce(_, _, _, _, _) do
    {:error, "invalid request"}
  end

  defp validate_info_hash!(info_hash) do
    unless is_binary(info_hash) and byte_size(info_hash) == 20 do
      raise "invalid info hash"
    end
  end

  defp validate_peer_id!(peer_id) do
    unless is_binary(peer_id) and byte_size(peer_id) == 20 do
      raise "invalid peer ID"
    end
  end

  defp validate_ip_address!({{a, b, c, d}, port}) do
    unless a in 0..255 and b in 0..255 and c in 0..255 and d in 0..255 and port in 0..65_535 do
      raise "invalid IP address"
    end
  end

  defp validate_byte_count!(count) do
    unless is_number(count) and count >= 0 do
      raise "invalid byte count"
    end
  end

  @doc """
  Get complete, incomplete, and all-time-downloaded counts for a torrent.
  """
  def scrape(info_hash) do
    validate_info_hash!(info_hash)

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

    {:ok,
     %{
       complete: Enum.at(results, 0),
       incomplete: Enum.at(results, 1),
       downloaded: downloaded
     }}
  end

  @doc """
  Delete all information relevant to a torrent.
  """
  def drop(info_hash) do
    validate_info_hash!(info_hash)
    info_hash = Base.encode16(info_hash, case: :lower)

    delete_commands =
      Redix.pipeline!(:redix, [
        ["SMEMBERS", "torrent:#{info_hash}:peers"],
        ["SREM", "torrents", info_hash],
        ["DEL", "torrent:#{info_hash}:downloaded"],
        ["DEL", "torrent:#{info_hash}:complete-peers"],
        ["DEL", "torrent:#{info_hash}:incomplete-peers"],
        ["DEL", "torrent:#{info_hash}:peers"]
      ])
      |> List.first()
      |> Enum.flat_map(fn peer_id ->
        [
          ["DEL", "peer:#{peer_id}:address"],
          ["DEL", "peer:#{peer_id}:last_contacted"]
        ]
      end)

    if Enum.any?(delete_commands) do
      Redix.pipeline!(:redix, delete_commands)
    end

    :ok
  end

  @doc """
  Remove all expired peers from the server.
  """
  def clean(ttl) do
    info_hashes = Redix.command!(:redix, ["SMEMBERS", "torrents"])

    peer_ids_for_hash =
      if Enum.any?(info_hashes) do
        Redix.pipeline!(:redix, Enum.map(info_hashes, &["SMEMBERS", "torrent:#{&1}:peers"]))
      else
        []
      end

    peer_ids = Enum.concat(peer_ids_for_hash)

    peer_last_contacted_dates =
      if Enum.any?(peer_ids) do
        Redix.pipeline!(:redix, Enum.map(peer_ids, &["GET", "peer:#{&1}:last_contacted"]))
      else
        []
      end
      |> Enum.map(fn last_contacted ->
        if last_contacted do
          {:ok, timestamp, _offset} = DateTime.from_iso8601(last_contacted)
          timestamp
        else
          nil
        end
      end)

    timestamps_for_peers = Enum.zip(peer_ids, peer_last_contacted_dates) |> Map.new()

    report =
      Enum.zip(info_hashes, peer_ids_for_hash)
      |> Map.new(fn {info_hash, peer_ids} ->
        peer_timestamps = Map.take(timestamps_for_peers, peer_ids)

        {info_hash, peer_timestamps}
      end)

    now = DateTime.utc_now()

    expired_peers_by_hash =
      Map.new(report, fn {info_hash, peer_timestamps} ->
        expired_peers_for_hash =
          Enum.filter(peer_timestamps, fn {_peer_id, timestamp} ->
            is_nil(timestamp) or not active?(timestamp, now, ttl)
          end)
          |> Map.new()
          |> Map.keys()

        {info_hash, expired_peers_for_hash}
      end)
      |> Enum.filter(fn {_info_hash, expired_peers} ->
        Enum.any?(expired_peers)
      end)

    drops =
      Enum.flat_map(expired_peers_by_hash, fn {info_hash, peers} ->
        set_drops = [
          ["SREM", "torrent:#{info_hash}:complete-peers"] ++ peers,
          ["SREM", "torrent:#{info_hash}:incomplete-peers"] ++ peers
        ]

        peer_drops =
          Enum.flat_map(peers, fn peer_id ->
            [
              ["DEL", "peer:#{peer_id}:address"],
              ["DEL", "peer:#{peer_id}:last_contacted"]
            ]
          end)

        set_drops ++ peer_drops
      end)

    if Enum.any?(drops) do
      Redix.pipeline!(:redix, drops)
    end

    :ok
  end

  defp active?(timestamp, now, ttl) do
    expiration = DateTime.add(timestamp, ttl, :second)

    DateTime.compare(now, expiration) in [:lt, :eq]
  end

  @doc """
  Get the number of torrents the server knows about.
  """
  def count_torrents do
    Redix.command!(:redix, ["SCARD", "torrents"])
  end

  @doc """
  Get the number of peers the server knows about.
  """
  def count_peers do
    count_commands =
      Redix.command!(:redix, ["SMEMBERS", "torrents"])
      |> Enum.map(&["SCARD", "torrent:#{&1}:peers"])

    if Enum.any?(count_commands) do
      Redix.pipeline!(:redix, count_commands)
      |> Enum.sum()
    else
      0
    end
  end
end
