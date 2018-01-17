import TestHelper

defmodule Extracker.HTTP.HandlerTest do
  use ExUnit.Case
  doctest Extracker.HTTP.Handler

  setup do
    Extracker.set_interval 9000
  end

  defp req(params) do
    HTTPotion.get("localhost:6969?" <> URI.encode_query(params))
  end

  test "returns content type of text/plain" do
    resp = req(request_query())
    assert resp.headers["content-type"] == "text/plain"
  end

  test "returns status code 200" do
    resp = req(request_query())

    assert resp.status_code == 200
  end

  test "returns an interval value" do
    body = req(request_query()).body
    {:ok, body_data} = ExBencode.decode(body)

    assert body_data["interval"] == 9_000
  end

  test "returns a peer value" do
    body = req(request_query()).body
    {:ok, body_data} = ExBencode.decode(body)

    expected_peer = %{"ip" => "127.0.0.1", "peer_id" => <<1>>, "port" => 8001}

    assert expected_peer in body_data["peers"]
  end

  test "accepts a real query" do
    resp = HTTPotion.get("localhost:6969?" <> real_request())

    assert resp.status_code == 200
  end

  test "compacts peers, if requested" do
    body = req(Map.put(request_query(), "compact", 1)).body
    {:ok, body_data} = ExBencode.decode(body)

    expected_peer = <<127, 0, 0, 1, 8001 :: 16>>

    assert body_data["peers"] == expected_peer
  end
end
