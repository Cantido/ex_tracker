# SPDX-FileCopyrightText: 2021 Rosa Richter
#
# SPDX-License-Identifier: MIT

defmodule Extracker.Telemetry do
  @moduledoc """
  Integration with `:telemetry`.
  """

  @doc """
  Count the number of torrents present on the server and emit as a telemetry event.
  """
  def count_torrents do
    count = Extracker.count_torrents()
    :telemetry.execute([:extracker, :torrents], %{count: count})
  end

  @doc """
  Count the number of peers present on the server and emit as a telemetry event.
  """
  def count_peers do
    count = Extracker.count_peers()

    :telemetry.execute([:extracker, :peers], %{count: count})
  end
end
