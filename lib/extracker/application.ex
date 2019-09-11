defmodule Extracker.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    extracker_opts = [
      interval_s: cfg(:interval_s),
      cleanup_interval_ms: cfg(:cleanup_interval_ms)
    ]

    children = [
      {Extracker, extracker_opts},
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

  defp cfg(key) do
    Application.fetch_env!(:extracker, key)
  end
end
