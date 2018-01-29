alias ExtrackerServer.HTTP.Format
alias ExtrackerServer.HTTP.Handler.Ring.Response

defmodule ExtrackerServer.BEP.CompactPeers do
  def handler(hnd) do
    fn(req) ->
      {:ok, %{body: %{peers: _}} = resp} = hnd.(req)

      new_response =
        if req.query_params.compact == 1 do
          Response.update_body(resp, &compact_peers/1)
        else
          Response.update_body(resp, &format_peers/1)
        end

      {:ok, new_response}
    end
  end

  defp format_peers(body) do
    case Format.format(body) do
      {:ok, str} -> str
    end
  end

  def compact_peers(result) do
    peers = Enum.map(result.peers, &compact_peer/1) |> Enum.join()
    %{result | peers: peers}
  end

  defp compact_peer(%{peer_id: _, ip: {a, b, c, d}, port: port}) do
    <<a, b, c, d, port :: 16>>
  end
end
