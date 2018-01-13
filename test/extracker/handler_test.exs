defmodule Extracker.HandlerTest do
  use ExUnit.Case
  doctest Extracker.Handler

  test "returns content type of text/plain" do
    {:ok, resp} = HTTPoison.get("localhost:6969", TestUtils.request_query())

    assert "text/plain" == :orddict.fetch("content-type", resp.headers)
  end
end
