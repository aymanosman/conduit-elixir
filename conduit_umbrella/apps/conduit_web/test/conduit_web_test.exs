defmodule ConduitWebTest do
  use ExUnit.Case
  doctest ConduitWeb

  test "greets the world" do
    assert ConduitWeb.hello() == :world
  end
end
