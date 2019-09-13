defmodule MissTest do
  use ExUnit.Case
  doctest Miss

  test "greets the world" do
    assert Miss.hello() == :world
  end
end
