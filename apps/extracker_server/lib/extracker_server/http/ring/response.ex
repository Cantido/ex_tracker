defmodule ExtrackerServer.HTTP.Handler.Ring.Response do
  #  [
  #   :status,
  #   :headers,
  #   :body
  # ]

  def do_cowboy_response(resp, req) do
    :cowboy_req.reply(
      resp.status,
      Map.get(resp, :headers, %{}),
      resp.body,
      req
    )
  end


  def update_body(response, fun) do
    Map.update!(response, :body, fun)
  end

  def add_header(response, key, value) do
    Map.update(response, :headers, %{key => value}, &Map.put(&1, key, value))
  end
end
