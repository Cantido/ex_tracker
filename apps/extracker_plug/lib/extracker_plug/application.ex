defmodule ExtrackerPlug.Application do
  use Application

  def start(_type, _args) do
    children = [
      Plug.Adapters.Cowboy.child_spec(scheme: :http, plug: ExtrackerPlug, options: [port: 4001])
    ]

    opts = [strategy: :one_for_one, name: ExtrackerPlug.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
