# SPDX-FileCopyrightText: 2021 Rosa Richter
#
# SPDX-License-Identifier: MIT

defmodule Extracker.Announce.Failure do
  @moduledoc """
  Failure struct for the Tracker HTTP Protocol.
  """

  @type t :: %{
    failure_reason: String.t()
  }

  defstruct [
    :failure_reason
  ]
end
