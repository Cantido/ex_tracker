defmodule Extracker.HTTP.Handler do
  @moduledoc """
  Handle THP connections.
  """
  @behaviour :cowboy_handler
  require ExBencode
  require Logger

  ## Callbacks

  def init(req, state) do
    Logger.info("Handling request #{inspect(req, pretty: true)}")

    with {:ok, query_params} <- query_params(req),
         {:ok, query_result} <- query(query_params),
         {:ok, post_process} <- compact(query_params, query_result),
         {:ok, body} <- ExBencode.encode(post_process),
         res <- response(body, req),
         :ok = Logger.debug "Response body: #{inspect(body, pretty: true)}"
    do
      {:ok, res, state}
    else
      _ -> {:ok, failure_body(req), state}
    end
  end

  def compact(%{compact: 1}, query_result) do
    peers = Enum.map(query_result.peers, &compact_peer(&1)) |> Enum.join()
    IO.puts "Peers: #{inspect(peers)}"
    {:ok, %{query_result | peers: peers}}
  end

  def compact(_query_params, query_result) do
    {:ok, query_result}
  end

  def compact_peer(%{peer_id: _, ip: {a, b, c, d}, port: port}) do
    <<a, b, c, d, port :: 16>>
  end

  defp query(params) do
    {:ok, Extracker.request(params)}
  end

  defp query_params(req) do
    {source_ip, _source_port} = :cowboy_req.peer(req)

    params = [
      {:info_hash, :nonempty},
      {:peer_id, :nonempty},
      {:port, :int},
      {:uploaded, :int},
      {:downloaded, :int},
      {:left, :int},
      {:ip, [], source_ip},
      {:compact, :int, 0}
    ]

    {:ok, :cowboy_req.match_qs(params, req)}
  end

  defp failure_body(req) do
    response "d14:failure reason19:service unavailablee", req
  end

  defp response(body, req) do
    :cowboy_req.reply(
      200,
      %{"content-type" => "text/plain"},
      body,
      req
    )
  end
end
