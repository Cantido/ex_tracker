defmodule ExtrackerPlugTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts ExtrackerPlug.init([])

  test "returns hello world" do
    # Create a test connection
    conn = conn(:get, "/hello")

    # Invoke the plug
    conn = ExtrackerPlug.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "Hello world"
  end
end
