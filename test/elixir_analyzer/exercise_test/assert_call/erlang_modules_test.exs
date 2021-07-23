defmodule ElixirAnalyzer.ExerciseTest.AssertCall.ErlangTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.Support.AnalyzerVerification.AssertCall.Erlang

  test_exercise_analysis "Calling :rand.normal in function/0",
    comments: [
      "found a call to :rand in function/0",
      "found a call to :rand in module",
      "found a call to :rand.normal in function/0",
      "found a call to :rand.normal in module"
    ] do
    [
      defmodule AssertCallVerification do
        def function() do
          r = :rand.normal()
        end
      end,
      defmodule AssertCallVerification do
        alias :rand, as: Rand

        def function() do
          r = Rand.normal()
        end
      end,
      defmodule AssertCallVerification do
        alias :rand

        def function() do
          r = :rand.normal()
        end
      end
    ]
  end

  test_exercise_analysis "Searching for use of module with imported module will succeed",
    comments: [
      "found a call to :rand in function/0",
      "found a call to :rand in module",
      "found a call to :rand.normal in function/0",
      "found a call to :rand.normal in module"
    ] do
    [
      defmodule AssertCallVerification do
        import :rand

        def function() do
          r = normal()
        end
      end,
      defmodule AssertCallVerification do
        import :rand, only: [normal: 0]

        def function() do
          r = normal()
        end
      end,
      defmodule AssertCallVerification do
        import :rand, except: [normal: 0]

        def function() do
          import :rand, only: [normal: 0]
          r = normal()
        end
      end,
      defmodule AssertCallVerification do
        import :rand, only: :functions

        def function() do
          r = normal()
        end
      end
    ]
  end

  test_exercise_analysis "Calling :rand.normal outside of function/0",
    comments: [
      "found a call to :rand in module",
      "found a call to :rand.normal in module",
      "didn't find a call to :rand.normal/0 in function/0",
      "didn't find a call to a :rand function in function/0"
    ] do
    [
      defmodule AssertCallVerification do
        def function() do
        end

        r = :rand.normal()
      end,
      defmodule AssertCallVerification do
        def function() do
          import :rand, except: [normal: 0]
        end

        r = :rand.normal()
      end
    ]
  end

  test_exercise_analysis "Calling :rand.uniform in function/0",
    comments: [
      "found a call to :rand in function/0",
      "found a call to :rand in module",
      "didn't find a call to :rand.normal anywhere in module",
      "didn't find a call to :rand.normal/0 in function/0"
    ] do
    defmodule AssertCallVerification do
      def function() do
        r = :rand.uniform()
      end
    end
  end

  test_exercise_analysis "Calling :rand.uniform outside of function/0",
    comments: [
      "found a call to :rand in module",
      "didn't find a call to :rand.normal anywhere in module",
      "didn't find a call to :rand.normal/0 in function/0",
      "didn't find a call to a :rand function in function/0"
    ] do
    defmodule AssertCallVerification do
      def function() do
      end

      r = :rand.uniform()
    end
  end

  test_exercise_analysis "Calling no rand function",
    comments: [
      "didn't find a call to :rand.normal anywhere in module",
      "didn't find a call to :rand.normal/0 in function/0",
      "didn't find a call to a :rand function in function/0",
      "didn't find any call to a :rand function"
    ] do
    [
      defmodule AssertCallVerification do
        def function() do
        end
      end,
      defmodule AssertCallVerification do
        import :rand, except: [normal: 0]

        def function() do
          r = normal()
        end
      end
    ]
  end
end
