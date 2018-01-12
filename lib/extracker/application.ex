defmodule Extracker.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    port = Application.fetch_env!(:extracker, :port)

    dispatch = :cowboy_router.compile([
      {'_', [{"/", Extracker.Handler, []}]}
    ])

    {:ok, _} = :cowboy.start_clear(:extracker_http,
                                  [port: port],
                                  %{env: %{dispatch: dispatch}})

    children = [
      Extracker
    ]

    opts = [strategy: :one_for_one, name: Extracker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
