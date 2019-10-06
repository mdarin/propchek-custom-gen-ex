defmodule HelloProperTest do
  use ExUnit.Case
  doctest HelloProper

  test "greets the world" do
    assert HelloProper.hello() == :world
  end
end
