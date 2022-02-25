defmodule ElixirAnalyzer.TestSuite.ExampleTest do
  use ElixirAnalyzer.ExerciseTestCase,
      exercise_test_module: ElixirAnalyzer.TestSuite.Example

  test_exercise_analysis "perfect solution",
    comments: [] do
    defmodule Example do
      @moduledoc """
      Greets the user
      """
      def hello(name) do
        "Hello, #{name}!"
      end
    end
  end
end
