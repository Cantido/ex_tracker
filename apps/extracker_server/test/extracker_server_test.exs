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

  test "returns an empty scrape if there have been no announcements" do
    query = URI.encode_query(%{"info_hash" => "Torrent with no DLs-"})
    conn = conn(:get, "/scrape?" <> query)
    conn = ExtrackerServer.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert {:ok, body} = ExBencode.decode(conn.resp_body)

    assert Map.keys(body) == ["files"]
    assert body["files"] == %{"Torrent with no DLs-" => %{"complete" => 0, "downloaded" => 0, "incomplete" => 0}}
  end

  test "returns a scrape with a torrent" do
    announce_request = %{
      info_hash: "Scraped Info Hash---",
      peer_id: "Peer ID One---------",
      port: 56420,
      ip: "69.69.69.69",
      uploaded: 0,
      downloaded: 0,
      left: 5000000
    }
    announce_conn =
      conn(:get, "/announce?" <> URI.encode_query(announce_request))
      |> ExtrackerServer.call(@opts)
    assert announce_conn.state == :sent
    assert announce_conn.status == 200

    scrape_request = %{
      info_hash: "Scraped Info Hash---"
    }
    scrape_conn =
      conn(:get, "/scrape?" <> URI.encode_query(scrape_request))
      |> ExtrackerServer.call(@opts)
    assert scrape_conn.state == :sent
    assert scrape_conn.status == 200

    assert {:ok, body} = ExBencode.decode(scrape_conn.resp_body)

    assert Map.keys(body) == ["files"]
    files = body["files"]
    assert Map.keys(files) == ["Scraped Info Hash---"]
    assert files == %{"Scraped Info Hash---" => %{"complete" => 0, "downloaded" => 0, "incomplete" => 1}}
  end
end
