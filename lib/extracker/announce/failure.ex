# SPDX-FileCopyrightText: 2021 Rosa Richter
#
# SPDX-License-Identifier: MIT

defmodule Extracker.Announce.Failure do
  @moduledoc """
  Failure struct for the Tracker HTTP Protocol.
  """

  defstruct [
    :failure_reason
  ]
end
