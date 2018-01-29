alias ExtrackerServer.{TorrentRegistry, Torrent}

defmodule ExtrackerServer do
  use GenServer

  @moduledoc """
  A fast & scaleable BitTorrent tracker.
  """

  ## API

  @doc """
  Start the tracker server. Peer announcements will expire after `interval_s`
  seconds, unless they announce themselves again.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Set the number of seconds `i` that a peer will expire after.
  """
  def set_interval(i) when i >= 0 do
    GenServer.call(__MODULE__, {:set_interval, i})
  end

  @doc """
  Set the number of milliseconds `i` that the server will wait before
  removing expired peers.
  """
  def set_cleanup_interval(i) when i > 0 do
    GenServer.call(__MODULE__, {:set_cleanup_interval, i})
  end

  @doc """
  Announce a peer to the tracker.
  """
  def request(req)

  def request(%{info_hash: _, peer_id: _, port: _, uploaded: _, downloaded: _, left: _, ip: _} = req) do
    GenServer.call(__MODULE__, {:announce, req})
  end

  def request(_req) do
    %{ failure_reason: "invalid request" }
  end

  ## Callbacks

  defstruct registry: TorrentRegistry.new(),
            interval_s: 9_000,
            cleanup_interval_ms: 1_000,
            cleanup_timer: nil

  def new do
    %ExtrackerServer{}
  end

  def init([interval_s: interval_s, cleanup_interval_ms: cleanup_interval_ms]) do
    state = %{
      new() |
        interval_s: interval_s,
        cleanup_interval_ms: cleanup_interval_ms
      } |> schedule_cleanup()
    {:ok, state}
  end

  def handle_call({:announce, %{info_hash: info_hash} = req}, _from, state) do
    peer = struct(ExtrackerServer.Peer, req)
        |> Map.put(:last_announce, System.monotonic_time(:seconds))

    registry1 = state.registry
             |> TorrentRegistry.add_peer_to_torrent(info_hash, peer)

    peers = TorrentRegistry.lookup(registry1, info_hash)
          |> Torrent.peers()
          |> strip_peers()

    {
      :reply,
      %{
        interval_s: state.interval_s,
        peers: Enum.to_list(peers)
      },
      %{state | registry: registry1}
    }
  end

  def handle_call({:set_interval, i}, _from, state) do
    {:reply, :ok, %{state | interval_s: i}}
  end

  def handle_call({:set_cleanup_interval, i}, _from, state) do
    state1 = state
          |> cancel_cleanup()
          |> Map.put(:cleanup_interval_ms, i)
          |> schedule_cleanup()

    {:reply, :ok, state1}
  end

  def handle_info(:clean, state) do
    state1 = state |> clean() |> schedule_cleanup()
    {:noreply, state1}
  end

  # Strip extra data from peers that we don't want in the return value
  defp strip_peers(peers) do
    Enum.map(peers, &Map.take(&1, [:ip, :peer_id, :port]))
  end

  defp cancel_cleanup(state) do
    _ = Process.cancel_timer(state.cleanup_timer)
    %{state | cleanup_timer: nil}
  end

  defp schedule_cleanup(state) do
    timer = Process.send_after(self(), :clean, state.cleanup_interval_ms)
    %{state | cleanup_timer: timer}
  end

  defp clean(state) do
    registry1 =
      TorrentRegistry.clean_torrents(
        state.registry,
        state.interval_s,
        System.monotonic_time(:seconds))

    %{state | registry: registry1}
  end
end
