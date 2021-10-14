defmodule Extracker.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {DynamicSupervisor, [strategy: :one_for_one, name: Extracker.TorrentSupervisor]},
      {Registry, [keys: :unique, name: Extracker.TorrentRegistry]},

      {Bandit, plug: Extracker.Router, scheme: :http, options: [port: 6969]}
    ]

    opts = [strategy: :one_for_one, name: Extracker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
