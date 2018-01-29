defmodule ExtrackerServer.HTTP.Handler.Ring.Request do
  #  [
  #   :server_port,
  #   :server_name,
  #   :remote_addr,
  #   :uri,
  #   :query_string,
  #   :scheme,
  #   :request_method,
  #   :protocol,
  #   :ssl_client_cert,
  #   :headers,
  #   :body
  # ]

  def from_cowboy(cbreq) do
    {:ok, body, cbreq} = :cowboy_req.read_body(cbreq)

    %{
      server_port: :cowboy_req.port(cbreq),
      server_name: :cowboy_req.host(cbreq),
      remote_addr: :cowboy_req.peer(cbreq),
      uri: :cowboy_req.path(cbreq),
      query_string: :cowboy_req.qs(cbreq),
      scheme: :cowboy_req.scheme(cbreq),
      request_method: :cowboy_req.method(cbreq),
      protocol: :cowboy_req.version(cbreq),
      ssl_client_cert: :cowboy_req.cert(cbreq),
      headers: :cowboy_req.headers(cbreq),
      body: body
    }
  end
end
