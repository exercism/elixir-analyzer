defmodule ElixirAnalyzer.ExerciseTest.Feature.BlockIncludesTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.Support.AnalyzerVerification.Feature.BlockIncludes

  test_exercise_analysis "code with an :ok in it",
    comments_exclude: ["cannot detect :ok"] do
    [
      defmodule MyModule do
        def foo() do
          :ok
        end
      end,
      defmodule MyModule do
        def foo() do
          x = "hi"
          :ok
        end
      end,
      defmodule MyModule do
        def foo(:ok) do
          IO.puts("hello")
        end
      end,
      defmodule MyModule do
        def foo() do
          cond do
            _ -> :ok
          end
        end
      end,
      defmodule MyModule do
        def foo() when :ok do
          true
        end
      end
    ]
  end

  test_exercise_analysis "code with two lines",
    comments_exclude: ["cannot detect two lines"] do
    [
      defmodule MyModule do
        def foo() do
          name = "Bob"
          greeting = "hi #{name}"
        end
      end,
      defmodule MyModule do
        def foo() do
          something = :before
          name = "Bob"
          something = :between
          greeting = "hi #{name}"
          something = :after
        end
      end,
      defmodule MyModule do
        def foo() do
          cond do
            false ->
              name = "Bob"
              greeting = "hi #{name}"

            true ->
              name = "Eve"
          end
        end
      end,
      defmodule MyModule do
        def foo() do
          if nil do
            name = "Bob"
            greeting = "hi #{name}"
          else
            name = "Eve"
          end
        end
      end,
      defmodule MyModule do
        def foo() do
          name = "Bob"
          name = "Bob"
          name = "Bob"
          greeting = "hi #{name}"
          greeting = "hi #{name}"
          greeting = "hi #{name}"
        end
      end
    ]
  end

  test_exercise_analysis "code with pattern matches",
    comments_exclude: ["cannot detect pattern matches"] do
    [
      defmodule MyModule do
        def foo(thing) do
          case thing do
            :ok -> "All good"
            _ -> "Whoops"
          end
        end
      end,
      defmodule MyModule do
        def foo(thing) do
          case thing do
            :ok -> "All good"
            :err -> "Error"
            _ -> "Whoops"
          end
        end
      end,
      defmodule MyModule do
        def foo(thing) do
          cond do
            :ok -> "All good"
            is_nil(thing) -> "No good"
            is_list(thing) -> "Not applicable"
            _ -> "Whoops"
          end
        end
      end
    ]
  end

  test_exercise_analysis "code with functions",
    comments_exclude: ["cannot detect functions"] do
    [
      defmodule MyModule do
        def foo() do
          :ok
        end

        def bar(baz) do
          {:err, baz}
        end
      end,
      defmodule MyModule do
        def foo() do
        end

        def bar(baz) do
        end
      end,
      defmodule MyModule do
        def foo() do
          IO.puts("!")
        end

        def baz(_, _) do
          :ok
        end

        def bar(_) do
          :a
          :b
          :c
        end
      end,
      defmodule MyModule do
        def baz(_, _), do: :ok

        def foo(), do: :hello

        def bar(baz), do: :bye
      end
    ]
  end

  test_exercise_analysis "code with nested blocks",
    comments_exclude: ["cannot detect nested blocks"] do
    [
      defmodule MyModule do
        def foo() do
          name = "Bob"
          greeting = "hi #{name}"
        end
      end,
      defmodule MyModule do
        def bar(baz) do
          nil
        end

        def foo() do
          age = 12
          name = "Bob"
          eyes = "Blue"
          greeting = "hi #{name}"
        end

        def baz(_) do
          :ok
        end
      end
    ]
  end
end