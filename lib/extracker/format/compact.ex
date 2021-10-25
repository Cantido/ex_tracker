# SPDX-FileCopyrightText: 2021 Rosa Richter
#
# SPDX-License-Identifier: MIT

defmodule Extracker.Format.Compact do
  @moduledoc """
  Formats peers into compact peer format.
  """

  @behaviour Extracker.Format

  def format(%{peers: peers} = body) when is_list(peers) do
    peers = Enum.map(peers, &compact_peer/1) |> Enum.join()
    %{body | peers: peers}
  end

  defp compact_peer(%{peer_id: _, ip: {a, b, c, d}, port: port})
       when a in 0..255 and
              b in 0..255 and
              c in 0..255 and
              d in 0..255 and
              port in 0..65_535 do
    <<a, b, c, d, port::16>>
  end
end
