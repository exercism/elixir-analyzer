defmodule ElixirAnalyzer.ExerciseTest.AssertCall.ModuleLevelCallTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.Support.AnalyzerVerification.AssertCall.ModuleLevelCall

  test_exercise_analysis "calls in function bodies count", comments: [] do
    [
      defmodule AssertCallVerification do
        def main_function() do
          [0, 1]
          |> Enum.map(&(&1 + 1))
          |> List.to_tuple()
          |> elem(0)
        end
      end,
      defmodule AssertCallVerification do
        defp main_function() do
          [0, 1]
          |> Enum.map(&(&1 + 1))
          |> List.to_tuple()
          |> elem(0)
        end
      end
    ]
  end

  test_exercise_analysis "calls in macro bodies count if no calling_fn specified",
    comments: ["didn't find any call to List.to_tuple/1 from main_function/0"] do
    [
      defmodule AssertCallVerification do
        defmacro main_function() do
          [0, 1]
          |> Enum.map(&(&1 + 1))
          |> List.to_tuple()
          |> elem(0)
        end
      end,
      defmodule AssertCallVerification do
        defmacrop main_function() do
          [0, 1]
          |> Enum.map(&(&1 + 1))
          |> List.to_tuple()
          |> elem(0)
        end
      end
    ]
  end

  test_exercise_analysis "module level calls do not count",
    comments: [
      "didn't find any call to Enum.map/2 from anywhere",
      "didn't find any call to List.to_tuple/1 from main_function/0"
    ] do
    [
      defmodule AssertCallVerification do
        def main_function() do
          1
        end
      end,
      defmodule AssertCallVerification do
        {@one, @two} = List.to_tuple([1, 2])

        def main_function() do
          @one
        end
      end,
      defmodule AssertCallVerification do
        {@one, @two} =
          [0, 1]
          |> Enum.map(&(&1 + 1))
          |> List.to_tuple()

        def main_function() do
          @one
        end
      end
    ]
  end
end
