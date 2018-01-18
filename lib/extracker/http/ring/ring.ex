
defmodule Extracker.HTTP.Handler.Ring do
  alias Extracker.HTTP.Handler.Ring.{Request, Response}

  @doc """
  Returns a Cowboy handler function (the "init" callback) that executes
  the given middleware and handler. The resulting fun will read the request
  body and send the response for you, you only need to modify maps.

  Create a handler and middleware like this:

      def handler(req_map) do
        # Do some stuff...
        resp_map
      end

      def app do
        &handler/1
          |> middleware1()
          |> middleware2()
          |> middleware3()
      end

  Note that this means `middleware1` will be the last to touch the request
  object, and the first to touch the response object. The `handler` function
  should be a function that accepts a Ring-formatted request and returns a
  Ring-formatted response. The handler should not respond to the cowboy request
  itself.

  And then you can create your Cowboy behavior callback:

      def init(req, state) do
        app(req, state)
      end

  The `state` parameter will be merged into the request map, under the `state`
  key.

  The `middleware` is a decorator function that wraps a given handler,
  and returns a new handler that accepts a Ring request map and returns a
  Ring response map.  like so:

      def my_middleware(handler) do
        fn(req) ->
          req1 = modify_req(req)
          resp = handler.(req1)
          modify_resp(resp)
        end
      end
  """
  def app(handler) do
    fn(cbreq, state) ->
      {:ok, resp} = cbreq
        |> Request.from_cowboy()
        |> Map.put(:cowboy_request, cbreq)
        |> Map.put(:state, state)
        |> handler.()

      cbresp = Response.do_cowboy_response(resp, cbreq)

      {:ok, cbresp, resp.state}
    end
  end

  def no_op_middleware(handler) do
    fn(req) ->
      IO.puts "no-op middleware called"
      handler.(req)
    end
  end
end
