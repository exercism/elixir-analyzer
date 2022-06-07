defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.CompilerWarningsTest do
  use ExUnit.Case
  alias ElixirAnalyzer.ExerciseTest.CommonChecks.CompilerWarnings

  test "Implementing a protocol doesn't trigger a compiler warning" do
    filepath = "test_data/clock/perfect_solution/lib/clock.ex"
    assert CompilerWarnings.run([filepath]) == []
  end
end
