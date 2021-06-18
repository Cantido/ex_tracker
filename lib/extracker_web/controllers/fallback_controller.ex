defmodule ExtrackerWeb.FallbackController do
  use Phoenix.Controller
  alias ExtrackerWeb.ErrorView

  def call(conn, {:error, reason}) do
    text(conn, Bento.encode!(%{"failure reason" => reason}))
  end
end
