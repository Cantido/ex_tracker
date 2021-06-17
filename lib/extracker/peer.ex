defmodule Extracker.Peer do
  @moduledoc """
  Functions for manipulating tracked peers.
  """

  defguard is_peer_id(id) when is_binary(id) and byte_size(id) == 20

  @enforce_keys [
    :peer_id,
    :ip,
    :port
  ]
  defstruct [
    peer_id: nil,
    ip: nil,
    port: nil,
    last_announce: :never,
    download_state: :incomplete
  ]

  @doc """
  Create a peer with the given `peer_id`.

  ## Examples

      iex> Extracker.Peer.new("12345678901234567890", {127, 0, 0, 1}, 6969)
      %Extracker.Peer{ip: {127, 0, 0, 1}, last_announce: :never, peer_id: "12345678901234567890", port: 6969}

  """
  def new(peer_id, ip, port) when is_peer_id(peer_id) do
    %__MODULE__{peer_id: peer_id, ip: ip, port: port}
  end

  @doc """
  Create a peer with a specific `last_announce` timestamp, in seconds.

  ## Examples

      iex> Extracker.Peer.new("12345678901234567890", {127, 0, 0, 1}, 6969, ~U[2021-06-15 12:00:00Z])
      %Extracker.Peer{ip: {127, 0, 0, 1}, last_announce: ~U[2021-06-15 12:00:00Z], peer_id: "12345678901234567890", port: 6969}

  """
  def new(peer_id, ip, port, last_announce) when is_binary(peer_id) do
    %__MODULE__{peer_id: peer_id, ip: ip, port: port, last_announce: last_announce}
  end

  def announced(peer, timestamp) do
    %__MODULE__{peer | last_announce: timestamp}
  end

  @doc """
  Get the age of a `peer`.

  By default, the return value is in seconds, but you can override that with any `t:System.time_unit()`.

  ## Examples

      iex> peer = Extracker.Peer.new("12345678901234567890", {127, 0, 0, 1}, 6969, ~U[2021-06-14T00:00:00Z])
      iex> Extracker.Peer.age(peer, ~U[2021-06-14T00:00:10Z])
      10
  """
  def age(peer, current_time, unit \\ :second) do
    if peer.last_announce == :never do
      :infinity
    else
      DateTime.diff(current_time, peer.last_announce, unit)
    end
  end

  @doc """
  Check if a peer does not yet have the complete download.

  ## Examples

      iex> Extracker.Peer.new("12345678901234567890", {127, 0, 0, 1}, 6969)
      ...> |> Extracker.Peer.incomplete?()
      true
  """
  def incomplete?(peer)

  def incomplete?(%__MODULE__{download_state: :incomplete}), do: true
  def incomplete?(%__MODULE__{}), do: false

  @doc """
  Check if a peer does has the complete download.

  ## Examples

      iex> Extracker.Peer.new("12345678901234567890", {127, 0, 0, 1}, 6969)
      ...> |> Extracker.Peer.complete?()
      false
  """
  def complete?(%__MODULE__{download_state: :complete}), do: true
  def complete?(%__MODULE__{}), do: false

  @doc """
  Mark the peer as having completed a download.

  ## Examples

      iex> peer = Extracker.Peer.new("12345678901234567890", {127, 0, 0, 1}, 6969)
      ...> Extracker.Peer.complete?(peer)
      false
      iex> Extracker.Peer.completed(peer)
      ...> |> Extracker.Peer.complete?()
      true
  """
  def completed(%__MODULE__{} = peer), do: %{peer | download_state: :complete}
end
