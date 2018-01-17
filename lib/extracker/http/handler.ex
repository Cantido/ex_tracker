defmodule Extracker.HTTP.Handler do
  @moduledoc """
  Handle THP connections.
  """
  @behaviour :cowboy_handler
  require ExBencode

  ## Callbacks

  def init(req, state) do
    with {:ok, query_result} <- query(req),
         {:ok, body} <- ExBencode.encode(query_result),
         res <- response(body, req)
    do
      {:ok, res, state}
    else
      _ -> {:ok, failure_body(req), state}
    end
  end

  defp query(_req) do
    :error
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
