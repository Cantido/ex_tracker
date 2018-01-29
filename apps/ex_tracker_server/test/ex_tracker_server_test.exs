defmodule ExTrackerServerTest do
  use ExUnit.Case
  doctest ExTrackerServer

  test "greets the world" do
    assert ExTrackerServer.hello() == :world
  end
end
