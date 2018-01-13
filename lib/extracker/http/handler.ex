defmodule Extracker.HTTP.Handler do
  @behaviour :cowboy_handler

  def init(req, state) do

    res = :cowboy_req.reply(
      200,
      %{"content-type" => "text/plain"},
      "d14:failure reason19:service unavailablee",
      req
    )

    {:ok, res, state}
  end
end
