defmodule ExtrackerWeb.PageControllerTest do
  use ExtrackerWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "This is but a humble BitTorrent tracker. There is nothing to see here."
  end
end
