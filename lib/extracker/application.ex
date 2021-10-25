# SPDX-FileCopyrightText: 2021 Rosa Richter
#
# SPDX-License-Identifier: MIT

defmodule Extracker.Application do
  @moduledoc false

  use Application
  alias Vapor.Provider.Env

  def start(_type, _args) do
    providers = [
      %Env{
        bindings: [
          {:port, "PORT", default: 6969},
          {:interval, "INTERVAL", default: 120},
          {:redis, "REDIS", default: "redis://localhost:6379"}
        ]
      }
    ]

    config = Vapor.load!(providers)

    children = [
      {Redix, {config.redis, [name: :redix]}},
      {Bandit, plug: Extracker.Router, scheme: :http, options: [port: config.port]}
    ]

    opts = [strategy: :one_for_one, name: Extracker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
