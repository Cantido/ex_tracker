defmodule Extracker.TorrentTracker do
  use GenServer, restart: :temporary
  alias Extracker.Torrent
  alias Extracker.Announce.Response

  @interval_seconds 2 * 60

  def start_link(info_hash) do
    GenServer.start_link(__MODULE__, [], name: via(info_hash))
  end

  def init(_) do
    {:ok, Torrent.new()}
  end

  def announce(request) do
    GenServer.call(via(request.info_hash), {:announce, request})
  end

  def scrape(info_hash) do
    GenServer.call(via(info_hash), :scrape)
  end

  def drop(info_hash) do
    GenServer.call(via(info_hash), :stop)
  end

  def count_peers(info_hash) do
    GenServer.call(via(info_hash), :count_peers)
  end

  def via(info_hash) do
    {:via, Registry, {Extracker.TorrentRegistry, info_hash}}
  end

  def handle_call({:announce, request}, _from, torrent) do
    torrent =
      Torrent.drop_old_peers(torrent, DateTime.utc_now(), @interval_seconds, :second)
      |> Torrent.add_peer(request.peer_id, request.ip, request.port)
      |> Torrent.peer_announced(request.peer_id, DateTime.utc_now())

    torrent =
      case request.event do
        :completed -> Torrent.peer_completed(torrent, request.peer_id)
        :stopped -> Torrent.peer_stopped(torrent, request.peer_id)
        _ -> torrent
      end

    response_peers = Torrent.peers(torrent) |> Enum.reject(& &1.peer_id == request.peer_id)

    response = %Response{
      interval: @interval_seconds,
      complete: Torrent.count_complete(torrent),
      incomplete: Torrent.count_incomplete(torrent),
      peers: response_peers
    }

    {:reply, {:ok, response}, torrent}
  end

  def handle_call(:scrape, _from, torrent) do
    torrent = Torrent.drop_old_peers(torrent, DateTime.utc_now(), @interval_seconds, :second)

    resp = %{
      complete: Torrent.count_complete(torrent),
      downloaded: Torrent.count_downloaded(torrent),
      incomplete: Torrent.count_incomplete(torrent)
    }

    {:reply, {:ok, resp}, torrent}
  end

  def handle_call(:count_peers, _from, torrent) do
    torrent = Torrent.drop_old_peers(torrent, DateTime.utc_now(), @interval_seconds, :second)

    count = Torrent.count_active(torrent)

    {:reply, count, torrent}
  end

  def handle_call(:stop, _from, torrent) do
    {:reply, :normal, :ok, torrent}
  end
end
