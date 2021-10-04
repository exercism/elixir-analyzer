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
      end,
      defmodule MyModule do
        def concat_equal_lists() do
          [1, 2, 3] ++ [4, 5, 6]
        end
      end,
      defmodule MyModule do
        def append_element() do
          [1, 2, 3, 4, 5] ++ [6]
        end
      end
    ]
  end

  test_exercise_analysis "Solutions using [h] ++ t to prepend to list",
    comments: [Constants.solution_list_prepend_head()] do
    [
      defmodule MyModule do
        def prepend_ok(list) do
          [:ok] ++ [:foo]
        end
      end,
      defmodule MyModule do
        def foo_list(), do: [:foo, :bar, :baz]

        def prepend_ok(list) do
          [:ok] ++ foo_list()
        end
      end,
      defmodule MyModule do
        def foo_list(), do: [:foo, :bar, :baz]

        def prepend_ok(list) do
          foo_list() |> (&([:ok] ++ &1))
        end
      end,
      defmodule MyModule do
        def foo_list(), do: [:foo, :bar, :baz]

        def prepend_ok(list) do
          :ok |> (&([&1] ++ foo_list()))
        end
      end
    ]
  end
end
