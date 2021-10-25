# SPDX-FileCopyrightText: 2021 Rosa Richter
#
# SPDX-License-Identifier: MIT

defmodule Extracker.Telemetry do
  @moduledoc """
  Integration with `:telemetry`.
  """

  def count_torrents do
    count = Extracker.count_torrents()
    :telemetry.execute([:extracker, :torrents], %{count: count})
  end

  def count_peers do
    count = Extracker.count_peers()

    :telemetry.execute([:extracker, :peers], %{count: count})
  end
end
