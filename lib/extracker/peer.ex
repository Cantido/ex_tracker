defmodule Extracker.Peer do
  @enforce_keys [:peer_id]
  defstruct peer_id: <<>>,
            ip: {0, 0, 0, 0},
            port: 0,
            last_announce: :never

  def new(peer_id) when is_binary(peer_id) do
    %Extracker.Peer{peer_id: peer_id}
  end

  def new(peer_id, last_announce) when is_binary(peer_id) do
    %Extracker.Peer{peer_id: peer_id, last_announce: last_announce}
  end

  def too_old?(peer, max_age, current_time) when is_map(peer) and max_age >= 0 do
    age(peer, current_time) >= max_age
  end

  def age(peer, current_time) do
    current_time - peer.last_announce
  end
end
