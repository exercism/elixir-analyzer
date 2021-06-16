defmodule ElixirAnalyzer.ExerciseTest.AccumulateTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.Accumulate

  test_exercise_analysis "example solution",
    comments: [] do
    defmodule Accumulate do
      def accumulate([], _), do: []

      def accumulate([head | tail], fun) do
        [fun.(head)] ++ accumulate(tail, fun)
      end
    end
  end

  describe "forbids any method of iteration other than recursion" do
    test_exercise_analysis "detects Enum",
      comments: [Constants.accumulate_use_recursion()] do
      [
        defmodule Accumulate do
          def accumulate(list, fun), do: Enum.map(list, fun)
        end,
        defmodule Accumulate do
          import Enum
          def accumulate(list, fun), do: map(list, fun)
        end,
        defmodule Accumulate do
          import Enum, only: [map: 2]
          def accumulate(list, fun), do: map(list, fun)
        end,
        defmodule Accumulate do
          alias Enum, as: E
          def accumulate(list, fun), do: E.map(list, fun)
        end
      ]
    end

    test_exercise_analysis "detects Stream",
      comments: [Constants.accumulate_use_recursion()] do
      [
        defmodule Accumulate do
          def accumulate(list, fun), do: Stream.map(list, fun)
        end,
        defmodule Accumulate do
          import Stream
          def accumulate(list, fun), do: map(list, fun)
        end,
        defmodule Accumulate do
          import Stream, only: [map: 2]
          def accumulate(list, fun), do: map(list, fun)
        end,
        defmodule Accumulate do
          alias Stream, as: S
          def accumulate(list, fun), do: S.map(list, fun)
        end
      ]
    end

    test_exercise_analysis "detects List",
      comments: [Constants.accumulate_use_recursion()] do
      [
        defmodule Accumulate do
          def accumulate(list, fun), do: List.foldr(list, [], fn x, acc -> [fun.(x) | acc] end)
        end,
        defmodule Accumulate do
          import List
          def accumulate(list, fun), do: L.foldr(list, [], fn x, acc -> [fun.(x) | acc] end)
        end,
        defmodule Accumulate do
          import List, only: [foldr: 3]
          def accumulate(list, fun), do: foldr(list, [], fn x, acc -> [fun.(x) | acc] end)
        end,
        defmodule Accumulate do
          alias List, as: L
          def accumulate(list, fun), do: L.foldr(list, [], fn x, acc -> [fun.(x) | acc] end)
        end
      ]
    end

    test_exercise_analysis "detects list comprehensions",
      comments: [Constants.accumulate_use_recursion()] do
      defmodule Accumulate do
        def accumulate(list, fun) do
          for element <- list, into: [], do: fun.(element)
        end
      end
    end
  end
end
