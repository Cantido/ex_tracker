# SPDX-FileCopyrightText: 2021 Rosa Richter
#
# SPDX-License-Identifier: MIT

defmodule Extracker.Format do
  @moduledoc """
  Serializer for peers.
  """

  def format(body, :standard), do: Extracker.Format.Standard.format(body)
  def format(body, :compact), do: Extracker.Format.Compact.format(body)

  @callback format(%{
    interval: integer,
    peers: [%{ip: any, port: any, peer_id: any}]
  }) :: any
end
