# SPDX-FileCopyrightText: 2021 Rosa Richter
#
# SPDX-License-Identifier: MIT

defmodule Extracker do
  @moduledoc """
  A fast & scaleable BitTorrent tracker.
  """

  alias Extracker.TorrentTracker
  alias Extracker.Announce.Request

  defguardp is_ip_address(a, b, c, d) when a in 0..255 and b in 0..255 and c in 0..255 and d in 0..255
  defguardp is_ip_port(port) when port in 0..65_535
  defguardp is_info_hash(hash) when is_binary(hash) and byte_size(hash) == 20


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
    if Enum.empty?(Registry.lookup(Extracker.TorrentRegistry, hash)) do
      {:ok, _pid} = Extracker.TorrentSupervisor.start_child(hash)
    end

    req = %Request{
      info_hash: hash,
      peer_id: id,
      ip: {a, b, c, d},
      port: port,
      uploaded: ul,
      downloaded: dl,
      left: left,
      event: Keyword.get(opts, :event, :interval)
    }

    TorrentTracker.announce(req)
  end

  def announce(_, _, _, _, _) do
    {:error, "invalid request" }
  end

  defguard is_info_hash(hash)
    when is_binary(hash)
     and byte_size(hash) == 20


  def scrape(info_hash) when is_info_hash(info_hash) do
    if Enum.empty?(Registry.lookup(Extracker.TorrentRegistry, info_hash)) do
      %{
        files: %{
          info_hash => %{
            complete: 0,
            downloaded: 0,
            incomplete: 0
          }
        }
      }
    else
      TorrentTracker.scrape(info_hash)
    end
  end

  def scrape(_req) do
    {:error, "invalid request"}
  end

  def drop(info_hash) do
    TorrentTracker.drop(info_hash)
  end

  def count_torrents do
    count = Registry.count(Extracker.TorrentRegistry)

    :telemetry.execute([:extracker, :torrents], %{count: count})
  end

  def count_peers do
    count =
      Registry.select(Extracker.TorrentRegistry, [{{:"$1", :"$2", :"$3"}, [], [{{:"$1", :"$2", :"$3"}}]}])
      |> Enum.map(fn {info_hash, _pid, _val} ->
        Task.async(fn ->
          TorrentTracker.count_peers(info_hash)
        end)
      end)
      |> Task.await_many()
      |> Enum.sum()

    :telemetry.execute([:extracker, :peers], %{count: count})
  end
end
