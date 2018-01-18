alias Extracker.HTTP.{IPAddressConstraint, Format}
alias Extracker.HTTP.Logging, as: HTTPLogging
alias Extracker.HTTP.Handler.Ring
alias Extracker.HTTP.Handler.Ring.Response

defmodule Extracker.HTTP.Handler do
  @moduledoc """
  Handle THP connections.
  """
  @behaviour :cowboy_handler
  require ExBencode
  require Logger

  ## Callbacks

  def init(req, state) do
    app().(req, state)
  end

  def app do
    (&handler/1)
      |> middleware()
      |> Ring.app()
  end

  def middleware(handler) do
    handler
      |> Extracker.BEP.CompactPeers.handler()
      |> bencode_body()
      |> HTTPLogging.handler()
      |> wrap_params()
  end

  def handler(req) do
    {
      :ok,
      %{
        status: 200,
        body: Extracker.request(req.query_params)
      }
    }
  end

  defp wrap_params(handler) do
    fn(req) ->
      {:ok, new_query_params} = query_params(req.cowboy_request)
      handler.(Map.put(req, :query_params, new_query_params))
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
      {:ip, &IPAddressConstraint.ip_address/2, source_ip},
      {:compact, :int, 0}
    ]

    {:ok, :cowboy_req.match_qs(params, req)}
  end


  defp bencode_body(handler) do
    fn(req) ->
      {:ok, %{body: _} = resp} = handler.(req)

      bencoded_response = resp
        |> Response.update_body(&bencode/1)
        |> Response.add_header("content-type", "text/plain")

      {:ok, bencoded_response}
    end
  end

  defp bencode(term) do
    case ExBencode.encode(term) do
      {:ok, str} -> str
    end
  end
end
