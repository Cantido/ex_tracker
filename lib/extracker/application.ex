defmodule Extracker.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    {:ok, _} = Extracker.HTTP.start(cfg(:host), cfg(:port), cfg(:path))

    extracker_opts = [
      interval: cfg(:interval),
      cleanup_interval: cfg(:cleanup_interval)
    ]

    children = [
      {Extracker, extracker_opts}
    ]

    opts = [strategy: :one_for_one, name: Extracker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp cfg(key) do
    Application.fetch_env!(:extracker, key)
  end
end
