defmodule ElixirAnalyzer.ExerciseTest.AssertCall.FunctionParenthesesTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module:
      ElixirAnalyzer.Support.AnalyzerVerification.AssertCall.FunctionParentheses

  test_exercise_analysis "defining run/0",
    comments_exclude: [
      "did not match def run()",
      "did not match def run"
    ] do
    [
      defmodule MyModule do
        def run do
          :ok
        end
      end,
      defmodule MyModule do
        def run() do
          :ok
        end
      end
    ]
  end

  test_exercise_analysis "assigning run/0",
    comments_exclude: [
      "did not match run()",
      "did not match run"
    ] do
    [
      defmodule MyModule do
        def sprint() do
          a = run()
        end
      end,
      defmodule MyModule do
        def sprint() do
          a = run
        end
      end
    ]
  end

  test_exercise_analysis "using run/0 in a pipe",
    comments_exclude: [
      "did not match run() in a pipe",
      "did not match run in a pipe"
    ] do
    [
      defmodule MyModule do
        def sprint() do
          a = :start |> run()
        end
      end,
      defmodule MyModule do
        def sprint() do
          a = :start |> run() |> jump()
        end
      end,
      defmodule MyModule do
        def sprint() do
          a = :start |> run
        end
      end,
      defmodule MyModule do
        def sprint() do
          a = :start |> run |> jump()
        end
      end
    ]
  end

  test_exercise_analysis "not using any run/0",
    comments_include: [
      "did not match def run()",
      "did not match def run",
      "did not match run()",
      "did not match run",
      "did not match run() in a pipe",
      "did not match run in a pipe"
    ] do
    [
      defmodule MyModule do
        def sprint() do
          a = :start |> sprint() |> jump()
        end
      end
    ]
  end
end
