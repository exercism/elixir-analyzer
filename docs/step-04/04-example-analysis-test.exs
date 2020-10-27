defmodule ElixirAnalyzer.ExerciseTest.ExampleTest do
  use ElixirAnalyzer.ExerciseTestCase,
      exercise_test_module: ElixirAnalyzer.ExerciseTest.Example

  test_exercise_analysis "perfect solution",
    status: :approve,
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
