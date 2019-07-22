defmodule ExtrackerServer.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: ExtrackerServer, options: [port: 3000]}
    ]

    opts = [strategy: :one_for_one, name: ExtrackerServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
