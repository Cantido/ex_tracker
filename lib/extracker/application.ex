defmodule Extracker.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Extracker
    ]

    opts = [strategy: :one_for_one, name: Extracker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
