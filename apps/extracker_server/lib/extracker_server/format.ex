defmodule ExtrackerServer.Format do
  def format(body, :standard), do: ExtrackerServer.Format.Standard.format(body)
  def format(body, :compact), do: ExtrackerServer.Format.Compact.format(body)

  @callback format(%{
    interval: integer,
    peers: [%{ip: any, port: any, peer_id: any}]
  }) :: any
end
