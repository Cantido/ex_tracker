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

    with {:ok, query_result} <- query(req),
         {:ok, body} <- ExBencode.encode(query_result),
         res <- response(body, req),
         :ok = Logger.debug "Response body: #{inspect(body, pretty: true)}"
    do
      {:ok, res, state}
    else
      _ -> {:ok, failure_body(req), state}
    end
  end

  defp query(req) do
    with {:ok, params} <- query_params(req)
    do
      {:ok, Extracker.request(params)}
    else
      _ -> :error
    end
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
      {:ip, [], source_ip}
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
