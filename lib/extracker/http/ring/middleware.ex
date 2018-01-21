defmodule Extracker.HTTP.Handler.Ring.Middleware do
  def wrap_params(handler, param_defs) do
    fn(req) ->
      query_params = :cowboy_req.match_qs(param_defs, req.cowboy_request)
      handler.(Map.put(req, :query_params, query_params))
    end
  end
end
