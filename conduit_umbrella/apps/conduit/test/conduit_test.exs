defmodule ConduitTest do
  use ExUnit.Case
  doctest Conduit

  test "greets the world" do
    assert Conduit.hello() == :world
  end
end
