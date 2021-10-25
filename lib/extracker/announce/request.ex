# SPDX-FileCopyrightText: 2021 Rosa Richter
#
# SPDX-License-Identifier: MIT

defmodule Extracker.Announce.Request do
  @moduledoc """
  Request struct for the Tracker HTTP protocol.
  """

  @type t :: %{
          info_hash: binary(),
          peer_id: binary(),
          ip: :inet.ip4_address(),
          port: :inet.port_number(),
          uploaded: non_neg_integer(),
          downloaded: non_neg_integer(),
          left: non_neg_integer(),
          compact: boolean(),
          no_peer_id: boolean(),
          event: :interval | :started | :completed | :stopped,
          numwant: non_neg_integer(),
          key: binary(),
          tracker_id: binary()
        }

  @enforce_keys [
    :info_hash,
    :peer_id,
    :ip,
    :port,
    :uploaded,
    :downloaded,
    :left
  ]
  defstruct info_hash: nil,
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
end
