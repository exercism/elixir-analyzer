defmodule ElixirAnalyzerTest do
  use ExUnit.Case
  doctest ElixirAnalyzer

  test "greets the world" do
    assert ElixirAnalyzer.hello() == :world
  end
end
