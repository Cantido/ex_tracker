defmodule ExtrackerServer.Application do
  use Application

  def start(_type, _args) do
    children = [
      Plug.Adapters.Cowboy.child_spec(:http, ExtrackerServer, [])
    ]

    opts = [strategy: :one_for_one, name: ExtrackerServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
