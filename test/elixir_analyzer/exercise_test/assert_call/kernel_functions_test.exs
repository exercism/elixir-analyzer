defmodule ElixirAnalyzer.ExerciseTest.AssertCall.KernelTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.Support.AnalyzerVerification.AssertCall.Kernel

  test_exercise_analysis "Not calling anything",
    comments: [
      "didn't find a call to Kernel.dbg/0",
      "didn't find a call to dbg/0",
      "didn't find a call to Kernel.self/0",
      "didn't find a call to self/0",
      "didn't find a call to <<>>/1"
    ] do
    defmodule AssertCallVerification do
      def function() do
        :ok
      end
    end
  end

  test_exercise_analysis "Calling dbg/0",
    comments_exclude: ["didn't find a call to Kernel.dbg/0", "didn't find a call to dbg/0"] do
    [
      defmodule AssertCallVerification do
        def function() do
          Kernel.dbg()
        end
      end,
      defmodule AssertCallVerification do
        def function() do
          dbg()
        end
      end,
      defmodule AssertCallVerification do
        def function() do
          &Kernel.dbg/0
        end
      end,
      defmodule AssertCallVerification do
        def function() do
          &dbg/0
        end
      end
    ]
  end

  test_exercise_analysis "Calling self/0",
    comments_exclude: ["didn't find a call to Kernel.self/0", "didn't find a call to self/0"] do
    [
      defmodule AssertCallVerification do
        def function() do
          Kernel.self()
        end
      end,
      defmodule AssertCallVerification do
        def function() do
          self()
        end
      end,
      defmodule AssertCallVerification do
        def function() do
          &self/0
        end
      end
    ]
  end

  test_exercise_analysis "Calling <<>>/1",
    comments_exclude: [
      "didn't find a call to <<>>/1"
    ] do
    [
      defmodule AssertCallVerification do
        def function() do
          <<a, b, c>> = <<1, 2, 3>>
          a
        end
      end,
      defmodule AssertCallVerification do
        def function() do
          <<a, b, c>> = <<1, 2, 3>>

          if b > 2 do
            a + c
          else
            nil
          end
        end
      end
    ]
  end
end
