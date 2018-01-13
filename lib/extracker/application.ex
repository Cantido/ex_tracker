defmodule Extracker.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    interval = Application.fetch_env!(:extracker, :interval)
    port = Application.fetch_env!(:extracker, :port)
    path = Application.fetch_env!(:extracker, :path)

    dispatch = :cowboy_router.compile([
      {:_, [{path, Extracker.Handler, []}]}
    ])

    {:ok, _} = :cowboy.start_clear(:extracker_http,
                                  [port: port],
                                  %{env: %{dispatch: dispatch}})

    children = [
      {Extracker, [interval]}
    ]

    opts = [strategy: :one_for_one, name: Extracker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
