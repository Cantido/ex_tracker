# SPDX-FileCopyrightText: 2021 Rosa Richter
#
# SPDX-License-Identifier: MIT

defmodule Extracker.Announce.Response do
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
