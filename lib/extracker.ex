defmodule Extracker do
  @moduledoc """
  A fast & scaleable BitTorrent tracker.
  """

  alias Extracker.TorrentTracker
  alias Extracker.Announce.Request


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
  when is_binary(hash) and byte_size(hash) == 20
   and is_binary(id) and byte_size(id) == 20
   and port in 0..65535
   and ul >= 0 and dl >= 0 and left >= 0
   and a in 0..255 and b in 0..255 and c in 0..255 and d in 0..255 do
    if Enum.empty?(Registry.lookup(Extracker.TorrentRegistry, hash)) do
      {:ok, _pid} = DynamicSupervisor.start_child(Extracker.TorrentSupervisor, {Extracker.TorrentTracker, hash})
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
end
