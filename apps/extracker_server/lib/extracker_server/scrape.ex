defmodule ExtrackerServer.Scrape do
  use Plug.Builder

  def init(opts), do: opts

  def call(conn, _opts) do
    files = hashes(conn)
    |> Stream.map(fn x -> {x, Extracker.scrape(x)} end)
    |> Stream.reject(fn {k, _} -> k == "failure_reason" end)
    |> Map.new

    {:ok, body} = ExBencode.encode(%{files: files})

    send_resp(conn, 200, body)
  end

  defp hashes(conn) do
    conn.query_string
    |> URI.query_decoder
    |> Stream.filter(fn({k, _}) -> k == "info_hash" end)
    |> Stream.map(fn({_, v}) -> v end)
  end
end
