# SPDX-FileCopyrightText: 2021 Rosa Richter
#
# SPDX-License-Identifier: MIT

defmodule Extracker.Router do
  use Plug.Router

  if Mix.env == :dev do
    use Plug.Debugger
  end

  use Plug.ErrorHandler

  plug :match
  plug :dispatch

  get "/announce" do
    conn = fetch_query_params(conn)
    %{
      "info_hash" => info_hash,
      "peer_id" => peer_id,
      "port" => port,
      "uploaded" => uploaded,
      "downloaded" => downloaded,
      "left" => left
    } = conn.query_params

    info_hash = Base.decode16!(info_hash, case: :mixed)

    event =
      case Map.get(conn.query_params, "event", "") do
        "started" -> :started
        "stopped" -> :stopped
        "completed" -> :completed
        _ -> :interval
      end

    ip =
      if Map.has_key?(conn.query_params, "ip") do
        {:ok, iptuple} = :inet.parse_address(String.to_charlist(conn.query_params["ip"]))
        iptuple
      else
        conn.remote_ip
      end

    address = {ip, String.to_integer(port)}
    progress = {String.to_integer(uploaded), String.to_integer(downloaded), String.to_integer(left)}

    announce_result = Extracker.announce(
      info_hash,
      peer_id,
      address,
      progress,
      event: event
    )

    with {:ok, response} <- announce_result,
          format_type = format_type(conn),
          response_body = Extracker.Format.format(response, format_type),
          {:ok, response_binary} <- Bento.encode(Map.from_struct(response_body)) do
      send_resp(conn, 200, response_binary)
    end
  end

  get "/scrape" do
    results =
      hashes(conn)
      |> Map.new(fn x -> {x, Extracker.scrape(x)} end)

    failures = Enum.filter(results, fn {_hash, {status, _result}} -> status == :error end)

    if Enum.any?(failures) do
      encoded = Map.new(failures, fn {hash, failure} ->
        {Base.encode16(hash, case: :lower), failure}
      end)
      raise RuntimeError, "One or more scrapes failed: #{inspect encoded}"
    end

    successes =
      Map.new(results, fn {hash, {:ok, result}} -> {hash, result} end)

    case Bento.encode(successes) do
      {:ok, bin} -> send_resp(conn, 200, bin)
    end
  end

  defp format_type(conn) do
    if compact_peers?(conn), do: :compact, else: :standard
  end

  defp compact_peers?(conn) do
    conn.query_params["compact"] == "1"
  end

  defp hashes(conn) do
    conn.query_string
    |> URI.query_decoder
    |> Stream.filter(fn({k, _}) -> k == "info_hash" end)
    |> Stream.map(fn({_, v}) -> Base.decode16!(v) end)
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end

  def handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, Bento.encode!(%{"failure reason" => "internal server error"}))
  end
end
