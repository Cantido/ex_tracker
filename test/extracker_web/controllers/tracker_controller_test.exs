defmodule ExtrackerWeb.TrackerControllerTest do
  use ExtrackerWeb.ConnCase

  describe "announce" do
    test "returns an empty response on the first announce", %{conn: conn} do
      params = %{
        info_hash: :crypto.strong_rand_bytes(20),
        peer_id: :crypto.strong_rand_bytes(20),
        port: 8001,
        uploaded: 0,
        downloaded: 0,
        left: 0,
        event: "started"
      }
      |> URI.encode_query()

      conn = get(conn, "/announce?")

      assert text_response(conn, 200) =~ "Hello"
    end
  end
end
