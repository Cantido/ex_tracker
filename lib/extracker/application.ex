defmodule Extracker.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {DynamicSupervisor, [strategy: :one_for_one, name: Extracker.TorrentSupervisor]},
      {Registry, [keys: :unique, name: Extracker.TorrentRegistry]},
      ExtrackerWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Extracker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ExtrackerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
