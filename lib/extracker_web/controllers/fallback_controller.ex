defmodule Extracker.FallbackController do
  use Phoenix.Controller
  alias HelloWeb.ErrorView

  def call(conn, {:error, reason}) do
    text(conn, ExBencode.encode(%{"failure reason" => reason}))
  end
end
