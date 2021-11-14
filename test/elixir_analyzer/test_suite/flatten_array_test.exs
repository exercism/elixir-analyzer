defmodule ElixirAnalyzer.ExerciseTest.FlattenArrayTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.FlattenArray

  test_exercise_analysis "example solution",
    comments: [] do
    defmodule FlattenArray do
      def flatten(list) do
        do_flatten(list, [])
      end

      defp do_flatten([head | tail], flattened) when is_list(head) do
        do_flatten(head, do_flatten(tail, flattened))
      end

      defp do_flatten([nil | tail], flattened) do
        do_flatten(tail, flattened)
      end

      defp do_flatten([head | tail], flattened) do
        [head | do_flatten(tail, flattened)]
      end

      defp do_flatten([], flattened) do
        flattened
      end
    end
  end

  describe "forbids any method of iteration other than recursion" do
    test_exercise_analysis "detects Enum",
      comments: [Constants.flatten_array_use_recursion()] do
      defmodule FlattenArray do
        def flatten(list) do
          Enum.reduce(list, [], fn x, acc ->
            if x == nil do
              acc
            else
              if is_list(x) do
                acc ++ flatten(x)
              else
                acc ++ [x]
              end
            end
          end)
        end
      end
    end

    test_exercise_analysis "detects List",
      comments: [Constants.flatten_array_use_recursion()] do
      defmodule FlattenArray do
        def flatten(list) do
          List.flatten(list)
          |> List.foldr([], fn x, acc ->
            if x == nil do
              acc
            else
              [x | acc]
            end
          end)
        end
      end
    end
  end
end
