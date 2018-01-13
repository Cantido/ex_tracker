defmodule Extracker.HTTP do
  def start(host, port, path) do
    dispatch = :cowboy_router.compile([
      {:_, [{path, Extracker.HTTP.Handler, []}]}
    ])

    :cowboy.start_clear(:extracker_http,
                        [port: port],
                        %{env: %{dispatch: dispatch}})
  end
end
