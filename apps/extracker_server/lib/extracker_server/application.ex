defmodule ExtrackerServer.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    {:ok, _} = ExtrackerServer.HTTP.start(cfg(:host), cfg(:port), cfg(:path))

    children = []

    opts = [strategy: :one_for_one, name: ExtrackerServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp cfg(key) do
    Application.fetch_env!(:extracker_server, key)
  end
end
