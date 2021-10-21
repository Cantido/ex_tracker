# SPDX-FileCopyrightText: 2021 Rosa Richter
#
# SPDX-License-Identifier: MIT

defmodule Extracker.Announce.Request do
  @moduledoc """
  Request struct for the Tracker HTTP protocol.
  """

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
