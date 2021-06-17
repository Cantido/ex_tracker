defmodule Extracker.Announce.Request do
  @enforce_keys [
    :info_hash,
    :peer_id,
    :ip,
    :port,
    :uploaded,
    :downloaded,
    :left
  ]
  defstruct [
    info_hash: nil,
    peer_id: nil,
    ip: nil,
    port: nil,
    uploaded: nil,
    downloaded: nil,
    left: nil,
    compact: true,
    no_peer_id: false,
    event: :interval,
    numwant: 50,
    key: nil,
    tracker_id: nil
  ]
end
