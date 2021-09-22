defmodule ElixirAnalyzer.ExerciseTest.StrainTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.Strain

  test_exercise_analysis "example solution",
    comments: [] do
    defmodule Strain do
      def keep(list, fun) do
        do_keep(list, fun, [])
      end

      defp do_keep([], _, results), do: Enum.reverse(results)

      defp do_keep([head | tail], fun, results) do
        case apply(fun, [head]) do
          true -> do_keep(tail, fun, [head | results])
          _ -> do_keep(tail, fun, results)
        end
      end

      def discard(list, fun) do
        do_discard(list, fun, [])
      end

      defp do_discard([], _, results), do: Enum.reverse(results)

      defp do_discard([head | tail], fun, results) do
        case apply(fun, [head]) do
          true -> do_discard(tail, fun, results)
          _ -> do_discard(tail, fun, [head | results])
        end
      end
    end
  end

  describe "forbids any method of iteration other than recursion" do
    test_exercise_analysis "detects Enum",
      comments: [Constants.strain_use_recursion()] do
      defmodule Strain do
        def keep(list, fun), do: Enum.filter(list, fun)
        def discard(list, fun), do: Enum.reject(list, fun)
      end
    end

    test_exercise_analysis "detects Stream",
      comments: [Constants.strain_use_recursion()] do
      defmodule Strain do
        def keep(list, fun), do: Stream.filter(list, fun)
        def discard(list, fun), do: Stream.reject(list, fun)
      end
    end

    test_exercise_analysis "detects list comprehensions",
      comments: [Constants.strain_use_recursion()] do
      defmodule Strain do
        def keep(list, fun) do
          for e <- list, fun.(e), do: e
        end

        def discard(list, fun) do
          for e <- list, !fun.(e), do: e
        end
      end
    end
  end
end
