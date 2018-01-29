require Logger

defmodule Extracker.HTTP.Logging do
  def handler(handler) do
    fn(req) ->
      :ok = Logger.info("Handling request #{inspect(req.cowboy_request, pretty: true)}")
      :ok = Logger.debug("Parsed query parameters: #{pretty_params(req.query_params)}")

      {:ok, resp} = handler.(req)
      :ok = Logger.debug "Response: #{inspect(resp, pretty: true)}"
      {:ok, resp}
    end
  end


  defp pretty_params(params) do
    params
      |> Map.update!(:info_hash, &Base.encode16/1)
      |> Map.update!(:ip, &to_string(:inet.ntoa(&1)))
      |> Map.update!(:downloaded, &in_bytes/1)
      |> Map.update!(:uploaded, &in_bytes/1)
      |> Map.update!(:left, &in_bytes/1)
      |> inspect(pretty: true)
  end

  defp in_bytes(i) when is_integer(i) do
    to_string(i) <> "B"
  end
end
