defmodule Extracker.Application do
  @moduledoc false

  use Application
  alias Vapor.Provider.Env

  def start(_type, _args) do
    providers = [
      %Env{
        bindings: [
          {:port, "PORT", default: 6969},
          {:interval, "INTERVAL", default: 120}
        ]
      }
    ]

    config = Vapor.load!(providers)

    children = [
      {Extracker.TorrentSupervisor, interval: config.interval},
      {Registry, [keys: :unique, name: Extracker.TorrentRegistry]},

      {Bandit, plug: Extracker.Router, scheme: :http, options: [port: config.port]}
    ]

    opts = [strategy: :one_for_one, name: Extracker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
