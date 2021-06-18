defmodule ExtrackerWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Plug.Conn
      import Phoenix.ConnTest
      alias ExtrackerWeb.Router.Helpers, as: Routes

      @endpoint ExtrackerWeb.Endpoint
    end
  end

  setup do
    %{conn: Phoenix.ConnTest.build_conn()}
  end
end
