defmodule Extracker.Peer do
  @moduledoc """
  Functions for manipulating tracked peers.
  """
  @enforce_keys [:peer_id]
  defstruct peer_id: <<>>,
            ip: {0, 0, 0, 0},
            port: 0,
            last_announce: :never

  @doc """
  Create a peer with the given `peer_id`.
  """
  def new(peer_id) when is_binary(peer_id) do
    %Extracker.Peer{peer_id: peer_id}
  end

  @doc """
  Create a peer with a specific `last_announce` timestamp, in seconds.
  """
  def new(peer_id, last_announce) when is_binary(peer_id) do
    %Extracker.Peer{peer_id: peer_id, last_announce: last_announce}
  end

  @doc """
  Check if a `peer` is older than the given `max_age`, given the `current_time`.
  """
  def too_old?(peer, max_age, current_time) when is_map(peer) and max_age >= 0 do
    age(peer, current_time) >= max_age
  end

  @doc """
  Get the age of a `peer` given a `current_time`.
  """
  def age(peer, current_time) do
    current_time - peer.last_announce
  end
end
