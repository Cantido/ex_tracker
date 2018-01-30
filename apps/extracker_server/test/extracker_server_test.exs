defmodule ExtrackerServerTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts ExtrackerServer.init([])

  defp info_hash do
    <<210, 229,  63, 182,   3,
      101,  45, 153,  25, 145,
      182, 173,  35,  87, 167,
      162, 132,  90,  83,  25>>
  end

  defp request_params do
    %{
      "info_hash" => info_hash(),
      "peer_id" => "-TR2920-ytgm4shu94ut",
      "port" => 51413,
      "uploaded" => 0,
      "downloaded" => 0,
      "left" => 1899528192,
      "numwant" => 0,
      "event" => "started"
    }
  end

  test "returns hello world" do
    # Create a test connection
    conn = conn(:get, "/announce?" <> URI.encode_query(request_params()))

    # Invoke the plug
    conn = ExtrackerServer.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert {:ok, body} = ExBencode.decode(conn.resp_body)

    assert body["interval"] == 9_000
  end

  # setup do
  #   Extracker.set_interval 9000
  # end
  #
  # test "returns content type of text/plain" do
  #   resp = req(request_query())
  #   assert resp.headers["content-type"] == "text/plain"
  # end
  #
  # test "returns status code 200" do
  #   resp = req(request_query())
  #
  #   assert resp.status_code == 200
  # end
  #
  # test "returns an interval value" do
  #   body = req(request_query()).body
  #   {:ok, body_data} = ExBencode.decode(body)
  #
  #   assert body_data["interval"] == 9_000
  # end
  #
  # test "returns a peer value" do
  #   body = req(request_query()).body
  #   {:ok, body_data} = ExBencode.decode(body)
  #
  #   expected_peer = %{"ip" => "127.0.0.1", "peer_id" => <<1>>, "port" => 8001}
  #
  #   assert expected_peer in body_data["peers"]
  # end
  #
  # test "accepts a real query" do
  #   resp = HTTPotion.get("localhost:6969?" <> real_request())
  #
  #   assert resp.status_code == 200
  # end
  #
  # test "compacts peers, if requested" do
  #   body = req(Map.put(request_query(), :compact, 1)).body
  #   {:ok, body_data} = ExBencode.decode(body)
  #
  #   expected_peer = <<127, 0, 0, 1, 8001 :: 16>>
  #
  #   assert body_data["peers"] == expected_peer
  # end
end
