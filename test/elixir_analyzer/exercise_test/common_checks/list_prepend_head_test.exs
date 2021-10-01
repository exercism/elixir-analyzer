defmodule ElixirAnalyzer.Support.AnalyzerVerification.ListPrependHead do
  use ElixirAnalyzer.ExerciseTest
end

defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.ListPrependHeadTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.Support.AnalyzerVerification.ListPrependHead

  alias ElixirAnalyzer.Constants

  test_exercise_analysis "Solutions using [h | t] to prepend to list",
    comments: [] do
    [
      defmodule MyModule do
        def prepend_ok(list) do
          [:ok | list]
        end

        def concat_lists() do
          [1, 2, 3] ++ [4, 5, 6]
        end
      end
    ]
  end

  test_exercise_analysis "Solutions using [h] ++ t to prepend to list",
    comments: [Constants.solution_list_prepend_head()] do
    [
      defmodule MyModule do
        def prepend_ok(list) do
          [:ok] ++ list
        end
      end
    ]
  end
end
