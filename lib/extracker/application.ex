defmodule Extracker.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    {:ok, _} = Extracker.HTTP.start(cfg(:host), cfg(:port), cfg(:path))

    extracker_opts = [
      interval_s: cfg(:interval_s),
      cleanup_interval_ms: cfg(:cleanup_interval_ms)
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
