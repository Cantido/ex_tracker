defmodule Extracker.HTTP.Handler do
  @moduledoc """
  Handle THP connections.
  """
  @behaviour :cowboy_handler

  ## Callbacks
  
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
