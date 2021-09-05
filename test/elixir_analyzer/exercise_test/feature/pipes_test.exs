defmodule ElixirAnalyzer.ExerciseTest.Feature.PipesTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.Support.AnalyzerVerification.Feature.Pipes

  test_exercise_analysis "function with one parameter",
    comments_exclude: ["not one parameter"] do
    [
      defmodule MyModule do
        def hi(name) do
          foo(name)
        end
      end,
      # This case matches, because feature looks down the AST
      defmodule MyModule do
        def hi(name) do
          name |> foo(:ok)
        end
      end,
      defmodule MyModule do
        def hi(name) do
          name |> foo
        end
      end,
      defmodule MyModule do
        def hi(name) do
          name |> foo()
        end
      end,
      defmodule MyModule do
        def hi(name) do
          name |> String.downcase() |> foo()
        end
      end,
      defmodule MyModule do
        def hi(name) do
          name |> String.downcase() |> foo
        end
      end
    ]
  end

  test_exercise_analysis "function not with one parameter",
    comments_include: ["not one parameter"] do
    [
      defmodule MyModule do
        def hi(name) do
          foo()
        end
      end,
      defmodule MyModule do
        def hi(name) do
          foo
        end
      end
    ]
  end

  test_exercise_analysis "function with three parameter",
    comments_exclude: ["not three parameter"] do
    [
      defmodule MyModule do
        def hi(name) do
          foo(name, :ok, false)
        end
      end,
      # This case matches, because feature looks down the AST
      defmodule MyModule do
        def hi(name) do
          :woops |> foo(name, :ok, false)
        end
      end,
      defmodule MyModule do
        def hi(name) do
          name |> foo(:ok, false)
        end
      end,
      defmodule MyModule do
        def hi(name) do
          name |> String.downcase() |> foo(:ok, false)
        end
      end
    ]
  end

  test_exercise_analysis "function not with three parameter",
    comments_include: ["not three parameter"] do
    [
      defmodule MyModule do
        def hi(name) do
          foo(name, false)
        end
      end,
      defmodule MyModule do
        def hi(name) do
          name |> foo(false)
        end
      end,
      defmodule MyModule do
        def hi(name) do
          name |> String.downcase() |> foo
        end
      end
    ]
  end

  test_exercise_analysis "function with one piped parameter",
    comments_exclude: ["not one piped parameter", "not one piped parameter (no parens)"] do
    [
      defmodule MyModule do
        def hi(name) do
          name |> foo
        end
      end,
      defmodule MyModule do
        def hi(name) do
          name |> foo()
        end
      end,
      defmodule MyModule do
        def hi(name) do
          name |> String.downcase() |> foo()
        end
      end,
      defmodule MyModule do
        def hi(name) do
          name |> String.downcase() |> foo
        end
      end
    ]
  end

  test_exercise_analysis "function not with one piped parameter",
    comments_include: ["not one piped parameter", "not one piped parameter (no parens)"] do
    [
      defmodule MyModule do
        def hi(name) do
          foo(name)
        end
      end,
      defmodule MyModule do
        def hi(name) do
          name |> foo(:ok)
        end
      end
    ]
  end

  test_exercise_analysis "function with three parameter and one piped",
    comments_exclude: ["not three parameters with one piped"] do
    [
      defmodule MyModule do
        def hi(name) do
          name |> foo(:ok, false)
        end
      end,
      defmodule MyModule do
        def hi(name) do
          name |> String.downcase() |> foo(:ok, false)
        end
      end
    ]
  end

  test_exercise_analysis "function not with three parameter and one piped",
    comments_include: ["not three parameters with one piped"] do
    [
      defmodule MyModule do
        def hi(name) do
          foo(name, :ok, false)
        end
      end,
      defmodule MyModule do
        def hi(name) do
          name |> foo(:ok)
        end
      end,
      defmodule MyModule do
        def hi(name) do
          name |> String.downcase() |> foo(:ok)
        end
      end
    ]
  end
end
