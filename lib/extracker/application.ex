defmodule Extracker.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    port = Application.fetch_env!(:extracker, :port)
    path = Application.fetch_env!(:extracker, :path)

    {:ok, _} = Extracker.HTTP.start(:_, port, path)

    interval = Application.fetch_env!(:extracker, :interval)

    children = [
      {Extracker, [interval]}
    ]

    opts = [strategy: :one_for_one, name: Extracker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
