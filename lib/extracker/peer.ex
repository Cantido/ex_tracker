defmodule Extracker.Peer do
  @moduledoc """
  Functions for manipulating tracked peers.
  """
  @enforce_keys [:peer_id]
  defstruct peer_id: <<>>,
            ip: {0, 0, 0, 0},
            port: 0,
            last_announce: :never,
            download_state: :incomplete

  @doc """
  Create a peer with the given `peer_id`.

  ## Examples

      iex> Extracker.Peer.new(<<0>>)
      %Extracker.Peer{ip: {0, 0, 0, 0}, last_announce: :never, peer_id: <<0>>, port: 0}

  """
  def new(peer_id) when is_binary(peer_id) do
    %Extracker.Peer{peer_id: peer_id}
  end

  @doc """
  Create a peer with a specific `last_announce` timestamp, in seconds.

  ## Examples

      iex> Extracker.Peer.new(<<0>>, -576460725)
      %Extracker.Peer{ip: {0, 0, 0, 0}, last_announce: -576460725, peer_id: <<0>>, port: 0}

  """
  def new(peer_id, last_announce) when is_binary(peer_id) do
    %Extracker.Peer{peer_id: peer_id, last_announce: last_announce}
  end

  @doc """
  Check if a `peer` is older than the given `max_age`, given the `current_time`.

  ## Examples

      iex> peer = Extracker.Peer.new(<<0>>, 0)
      iex> Extracker.Peer.too_old?(peer, 5, 10)
      true

      iex> peer = Extracker.Peer.new(<<0>>, 0)
      iex> Extracker.Peer.too_old?(peer, 10, 7)
      false
  """
  def too_old?(peer, max_age, current_time) when is_map(peer) and max_age >= 0 do
    age(peer, current_time) >= max_age
  end

  @doc """
  Get the age of a `peer` given a `current_time`.

  ## Examples

      iex> peer = Extracker.Peer.new(<<0>>, 0)
      iex> Extracker.Peer.age(peer, 10)
      10
  """
  def age(peer, current_time) do
    current_time - peer.last_announce
  end

  def download_state(%Extracker.Peer{} = peer) do
    peer.download_state
  end

  def incomplete?(%Extracker.Peer{download_state: :incomplete}), do: true
  def incomplete?(%Extracker.Peer{}), do: false

  def completed(%Extracker.Peer{} = peer), do: %{peer | download_state: :complete}

  def complete?(%Extracker.Peer{download_state: :complete}), do: true
  def complete?(%Extracker.Peer{}), do: false
end
