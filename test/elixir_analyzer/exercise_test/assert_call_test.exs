defmodule ElixirAnalyzer.ExerciseTest.AssertCallTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.Support.AnalyzerVerification.AssertCall

  test_exercise_analysis "perfect solution",
    comments: [] do
    defmodule AssertCallVerification do
      def function() do
        result = helper()
        IO.puts(result)

        private_helper() |> IO.puts()
      end

      def helper do
        :helped
      end

      defp private_helper do
        :privately_helped
      end
    end
  end

  test_exercise_analysis "missing local call solution",
    comments: [
      "didn't find a local call to helper/0",
      "didn't find a local call to helper/0 within function/0"
    ] do
    defmodule AssertCallVerification do
      def function() do
        private_helper() |> IO.puts()
      end

      def helper do
        :helped
      end

      defp private_helper do
        :privately_helped
      end
    end
  end
end
