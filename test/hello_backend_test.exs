defmodule HelloBackendTest do
  use ExUnit.Case
  doctest HelloBackend

  test "greets the world" do
    assert HelloBackend.hello() == :world
  end
end
