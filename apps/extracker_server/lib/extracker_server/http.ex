defmodule ExtrackerServer.HTTP do
  @moduledoc """
  Implementation of the Tracker HTTP Protocol (THP).
  """

  @doc """
  Initialize the server component running at `host:port/path`.

  If you wish to bind the server to all hosts, provide the atom `:_`.
  """
  def start(host, port, path) do
    dispatch = :cowboy_router.compile([
      {host, [{path, ExtrackerServer.HTTP.Handler, []}]}
    ])

    :cowboy.start_clear(:extracker_server_http,
                        [port: port],
                        %{env: %{dispatch: dispatch}})
  end
end
