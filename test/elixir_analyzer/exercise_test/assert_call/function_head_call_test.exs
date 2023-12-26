defmodule ElixirAnalyzer.ExerciseTest.AssertCall.FunctionHeadCallTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.Support.AnalyzerVerification.AssertCall.FunctionHeadCall

  test_exercise_analysis "calls in function head count", comments: [] do
    [
      defmodule AssertCallVerification do
        def main_function(@jackpot) do
          :win
        end

        def main_function(x) when x > 100 do
          :too_much
        end

        def main_function([x | rest]) when is_integer(x) do
          main_function(x)
        end
      end,
      defmodule AssertCallVerification do
        def main_function(@jackpot) do
          :win
        end

        def main_function([x | rest]) when is_integer(x) and x > 100 do
          :too_much
        end
      end,
      defmodule AssertCallVerification do
        def main_function(x) when x == @jackpot do
          :win
        end

        def main_function(a, b, [x | rest]) when is_integer(x) and x > 100 do
          :too_much
        end
      end,
      defmodule AssertCallVerification do
        def main_function(x) when x == @jackpot do
          :win
        end

        def main_function(%{list: [x | rest]}) when is_integer(x) and x > 100 do
          :too_much
        end
      end
    ]
  end

  test_exercise_analysis "indirect calls in function head count", comments: [] do
    [
      defmodule AssertCallVerification do
        def main_function(x) do
          helper_function(x)
        end

        def helper_function(@jackpot) do
          :win
        end

        def helper_function([x | rest]) when is_integer(x) do
          main_function(x)
        end

        defp helper_function(x) when x > 100 do
          :too_much
        end
      end
    ]
  end

  test_exercise_analysis "calls from the wrong function",
    comments: [
      "didn't find any call to Kernel.is_integer/1 from main_function/1",
      "didn't find any call to Kernel.|/2 from main_function/1",
      "didn't find any call to Kernel.@/1 from main_function/1"
    ] do
    [
      defmodule AssertCallVerification do
        def main_function() do
          nil
        end

        def wrong_function(@jackpot) do
          :win
        end

        def wrong_function(x) when x > 100 do
          :too_much
        end

        def wrong_function([x | rest]) when is_integer(x) do
          wrong_function(x)
        end
      end
    ]
  end

  test_exercise_analysis "no calls",
    comments: [
      "didn't find any call to Kernel.>/2 from anywhere",
      "didn't find any call to Kernel.is_integer/1 from main_function/1",
      "didn't find any call to Kernel.|/2 from main_function/1",
      "didn't find any call to Kernel.@/1 from main_function/1"
    ] do
    [
      defmodule AssertCallVerification do
        def main_function(x) when x >= 100 do
          :too_much
        end
      end
    ]
  end
end
