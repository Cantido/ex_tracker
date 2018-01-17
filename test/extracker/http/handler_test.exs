defmodule Extracker.HTTP.HandlerTest do
  use ExUnit.Case
  doctest Extracker.HTTP.Handler

  defp req(params) do
    HTTPotion.get("localhost:6969", params: params)
  end

  test "returns content type of text/plain" do
    resp = req(TestUtils.request_query())
    assert resp.headers["content-type"] == "text/plain"
  end

  test "returns status code 200" do
    resp = req(TestUtils.request_query())

    assert resp.status_code == 200
  end

  # test "returns an interval value" do
  #   body = req(TestUtils.request_query()).body
  #   {:ok, body_data} = ExBencode.decode(body)
  #
  #   assert body_data["interval"] == 9_000
  # end
end
