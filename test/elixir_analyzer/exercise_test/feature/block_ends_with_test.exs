defmodule ElixirAnalyzer.ExerciseTest.Feature.BlockEndsWithTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.Support.AnalyzerVerification.Feature.BlockEndsWith

  describe "finding a single expression" do
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
            case {} do
              _ -> :ok
            end
          end
        end,
        defmodule MyModule do
          def foo() when :ok do
            true
          end
        end,
        defmodule MyModule do
          def foo() do
            :ok.lets_pretend_this_is_an_erlang_module()
            # Erlang function call counts as atom literal
          end
        end,
        defmodule MyModule do
          def foo() do
            :ok
            # Atoms are always found, even when they are not the last
            :nope
          end
        end
      ]
    end

    test_exercise_analysis "code not finishing by :ok",
      comments_include: ["cannot detect :ok"] do
      [
        defmodule MyModule do
          def foo() do
            :error
          end
        end,
        defmodule MyModule do
          def foo() do
            :ok_nope
          end
        end,
        defmodule MyModule do
          def ok() do
            # function name does not count as atom literal
          end
        end,
        defmodule MyModule do
          def foo() do
            ok()
            # function call doesn't count as atom literal
          end
        end
      ]
    end
  end

  test_exercise_analysis "code ending with two lines",
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

            nil ->
              name = "Alice"
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
        end
      end,
      defmodule MyModule do
        def foo() do
          # Duplicated last line is OK because it is still the same
          name = "Bob"
          name = "Bob"
          greeting = "hi #{name}"
          greeting = "hi #{name}"
        end
      end
    ]
  end

  test_exercise_analysis "code not ending with the two lines",
    comments_include: ["cannot detect two lines"] do
    [
      defmodule MyModule do
        def foo() do
        end
      end,
      defmodule MyModule do
        def foo() do
          # Not the last
          name = "Bob"
          greeting = "hi #{name}"
          something = :else
        end
      end,
      defmodule MyModule do
        def foo() do
          # Wrong order
          greeting = "hi #{name}"
          name = "Bob"
        end
      end,
      defmodule MyModule do
        def foo() do
          cond do
            # In different blocks
            false ->
              name = "Bob"

            true ->
              greeting = "hi #{name}"

            :truthy ->
              :ok
          end
        end
      end,
      defmodule MyModule do
        def foo() do
          if nil do
            name = "Bob"
          else
            greeting = "hi #{name}"
          end
        end
      end,
      defmodule MyModule do
        def foo() do
          name = "Bob"
        end
      end,
      defmodule MyModule do
        def foo() do
          greeting = "hi #{name}"
        end
      end
    ]
  end

  test_exercise_analysis "code ending with pattern matches",
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
          case thing do
            :ok -> "All good"
            :ok -> "All good"
            :err -> "Error"
            _ -> "Whoops"
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

  test_exercise_analysis "code not ending with pattern matches",
    comments_include: ["cannot detect pattern matches"] do
    [
      defmodule MyModule do
        def foo(thing) do
          case thing do
            :ok -> "All good"
          end
        end
      end,
      defmodule MyModule do
        def foo(thing) do
          case thing do
            _ -> "Whoops"
          end
        end
      end,
      defmodule MyModule do
        def foo(thing) do
          case thing do
            # Wrong order
            _ -> "Whoops"
            :ok -> "All good"
          end
        end
      end,
      defmodule MyModule do
        def foo(thing) do
          case thing do
            # Not the last
            :ok -> "All good"
            _ -> "Whoops"
            :err -> "Error"
          end
        end
      end,
      defmodule MyModule do
        def foo(thing) do
          cond do
            :ok -> "All good"
            is_nil(thing) -> "No good"
          end

          cond do
            is_list(thing) -> "Not applicable"
            is_nil(thin) -> "Even worse"
            _ -> "Whoops"
          end
        end
      end
    ]
  end

  test_exercise_analysis "code ending with functions",
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

  test_exercise_analysis "code not ending with functions",
    comments_include: ["cannot detect functions"] do
    [
      defmodule MyModule do
        def foo() do
          :ok
        end
      end,
      defmodule MyModule do
        def bar(baz) do
          {:err, baz}
        end
      end,
      defmodule MyModule do
        def foo() do
        end

        def bar(baz) do
        end

        def hi() do
          :hello
        end
      end,
      defmodule MyModule do
        # wrong order
        def bar(baz) do
        end

        def foo() do
        end
      end,
      defmodule MyModule do
        # one argument in foo
        def foo(?!) do
          IO.puts("!")
        end

        def bar(_) do
          :a
          :b
          :c
        end
      end,
      defmodule MyModule do
        def foo(), do: :hello

        # Missing argument
        def bar(), do: :bye
      end
    ]
  end

  test_exercise_analysis "code with a block finishing on a function with pipes",
    comments_exclude: ["cannot detect a block finishing on a function"] do
    [
      defmodule MyModule do
        def foo() do
          final_function(:ok)
        end
      end,
      defmodule MyModule do
        def foo() do
          :ok |> final_function()
        end
      end,
      defmodule MyModule do
        def foo() do
          :ok |> baz(:error) |> final_function()
        end
      end
    ]
  end

  test_exercise_analysis "code with a block not finishing on a function with pipes",
    comments_include: ["cannot detect a block finishing on a function"] do
    [
      defmodule MyModule do
        def foo() do
          final_function(:ok)
          :super_final
        end
      end,
      defmodule MyModule do
        def foo() do
          :ok |> final_function() |> super_final()
        end
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
          greeting = "hi #{name}"
        end
      end
    ]
  end

  test_exercise_analysis "code without nested blocks",
    comments_include: ["cannot detect nested blocks"] do
    [
      defmodule MyModule do
        def foo() do
          name = "Bob"
        end
      end,
      defmodule MyModule do
        def foo() do
          name = "Bob"
          greeting = "hi #{name}"
        end

        def baz() do
        end
      end,
      defmodule MyModule do
        def foo() do
        end

        def bar() do
          age = 12
          name = "Bob"
          eyes = "Blue"
          greeting = "hi #{name}"
        end
      end
    ]
  end

  test_exercise_analysis "a block matches a full block",
    comments_exclude: ["could use two in a row", "could match a line and a block in a row"] do
    [
      defmodule MyModule do
        def foo() do
          :hello
          :goodbye
        end
      end
    ]
  end

  test_exercise_analysis "without context, :done will match anywhere",
    comments_exclude: ["without context: could not match a line"] do
    [
      defmodule MyModule do
        def foo() do
          # Not the last, but matches because foo() context was not provided
          :done
          x = 42
        end
      end
    ]
  end

  test_exercise_analysis "with context, :done will be as expected",
    comments_include: ["with context: could not match :done"] do
    [
      defmodule MyModule do
        def foo() do
          # Not the last, so doesn't match if foo() context is provided
          :done
          x = 42
        end
      end
    ]
  end

  test_exercise_analysis "with context, :done will be matched if last",
    comments_exclude: ["with context: could not match :done"] do
    [
      defmodule MyModule do
        def foo() do
          x = 42
          :done
        end
      end,
      defmodule MyModule do
        def foo() do
          :done
        end
      end
    ]
  end
end
