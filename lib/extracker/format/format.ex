defmodule Extracker.Format do
  def format(body, :standard), do: Extracker.Format.Standard.format(body)
  def format(body, :compact), do: Extracker.Format.Compact.format(body)

  @callback format(%{
    interval: integer,
    peers: [%{ip: any, port: any, peer_id: any}]
  }) :: any
end
