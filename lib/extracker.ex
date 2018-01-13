alias Extracker.TorrentRegistry

defmodule Extracker do
  use GenServer

  def start_link([interval]) do
    GenServer.start_link(__MODULE__, interval, name: __MODULE__)
  end

  def set_interval(i) when i >= 0 do
    GenServer.call(__MODULE__, {:set_interval, i})
  end

  def set_cleanup_interval(i) when i > 0 do
    GenServer.call(__MODULE__, {:set_cleanup_interval, i})
  end

  def request(%{info_hash: _, peer_id: _, port: _, uploaded: _, downloaded: _, left: _, ip: _} = req) do
    GenServer.call(__MODULE__, {:announce, req})
  end

  def request(_req) do
    %{ failure_reason: "invalid request" }
  end

  defstruct torrents: TorrentRegistry.new(),
            interval: 9_000,
            cleanup_interval: 1_000,
            cleanup_timer: nil

  def init(interval) do
    state = %Extracker{interval: interval} |> schedule_cleanup()
    {:ok, state}
  end

  def handle_call({:announce, %{info_hash: info_hash} = req}, _from, state) do
    peer = struct(Extracker.Peer, req)
        |> Map.put(:last_announce, System.monotonic_time(:seconds))

    torrents1 = state.torrents
             |> TorrentRegistry.add_peer_to_torrent(info_hash, peer)

    peers = TorrentRegistry.lookup(torrents1, info_hash).peers

    {
      :reply,
      %{
        interval: state.interval,
        peers: Enum.to_list(peers)
      },
      %{state | torrents: torrents1}
    }
  end

  def handle_call({:set_interval, i}, _from, state) do
    {:reply, :ok, %{state | interval: i}}
  end

  def handle_call({:set_cleanup_interval, i}, _from, state) do
    state1 = state
          |> cancel_cleanup()
          |> Map.put(:cleanup_interval, i)
          |> schedule_cleanup()

    {:reply, :ok, state1}
  end

  def handle_info(:clean, state) do
    state1 = state |> clean() |> schedule_cleanup()
    {:noreply, state1}
  end

  defp cancel_cleanup(state) do
    _ = Process.cancel_timer(state.cleanup_timer)
    %{state | cleanup_timer: nil}
  end

  defp schedule_cleanup(state) do
    timer = Process.send_after(self(), :clean, state.cleanup_interval)
    %{state | cleanup_timer: timer}
  end

  defp clean(state) do
    torrents1 =
      TorrentRegistry.clean_torrents(
        state.torrents,
        state.interval,
        System.monotonic_time(:seconds))

    %{state | torrents: torrents1}
  end
end
