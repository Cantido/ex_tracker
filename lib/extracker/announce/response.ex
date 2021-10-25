# SPDX-FileCopyrightText: 2021 Rosa Richter
#
# SPDX-License-Identifier: MIT

defmodule Extracker.Announce.Response do
  @moduledoc """
  Response struct for the Tracker HTTP protocol.
  """

  @type t :: %{
          warning_message: String.t(),
          interval: non_neg_integer(),
          min_interval: non_neg_integer(),
          tracker_id: binary(),
          complete: non_neg_integer(),
          incomplete: non_neg_integer(),
          peers: [peer]
        }

  @type peer :: %{
          peer_id: binary(),
          ip: :inet.ipv4_address(),
          port: :inet.port_number()
        }

  defstruct [
    :warning_message,
    :interval,
    :min_interval,
    :tracker_id,
    :complete,
    :incomplete,
    :peers
  ]
end
