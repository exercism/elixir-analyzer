defmodule ElixirAnalyzer.ExerciseTest.AssertCall.MultipleClauseFunctionsTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module:
      ElixirAnalyzer.Support.AnalyzerVerification.AssertCall.MultipleClauseFunctions

  test_exercise_analysis "Calling Map.new outside of the observed function",
    comments: [
      "didn't find a call to Map.new/0 in function/1"
    ] do
    [
      # Called in another function.
      defmodule AssertCallVerification do
        def function(b) do
          %{a: b}
        end

        def not_me(b) do
          Map.new() |> Map.put(:a, b)
        end
      end,
      # Called in module.
      defmodule AssertCallVerification do
        @not_me Map.new()

        def function(%{} = m) do
          Map.put(m, :a, 42)
        end
      end,
      # Text appears in documentation and comments
      defmodule AssertCallVerification do
        @moduledoc """
        Nothing in this module will call Map.new
        """

        @doc """
        We could call Map.new in this function, for example we could do :

            iex> Map.new()
            %{}

        But we won't do this !
        """
        def function(b) when is_integer(b) and b > 0 do
          # Map.new() is more verbose than %{}
          %{} |> Map.put(:a, b)
        end
      end
    ]
  end

  test_exercise_analysis "Calling Map.new in function without guards",
    comments: [
      "found a call to Map.new/0 in function/1"
    ] do
    [
      # Single clause function, no guards.
      defmodule AssertCallVerification do
        def function(b) do
          Map.new() |> Map.put(:a, b)
        end
      end,
      # Multiple clause functions with pattern matching in the arguments, no guards,
      # only one of the clauses calls Map.new/0. Using import.
      defmodule AssertCallVerification do
        import Map

        def function(%{} = m) do
          Map.put(m, :a, 42)
        end

        def function(b) do
          Map.put(new(), :a, b)
        end

        def function(_) do
          nil
        end
      end,
      # Multiple clause functions with pattern matching in the arguments, no guards,
      # multiple clauses call Map.new/0. Using alias.
      defmodule AssertCallVerification do
        alias Map, as: MyMap

        def function(%{} = m) do
          m |> Map.put(:a, 42)
        end

        def function([b | _]) do
          MyMap.new() |> Map.put(:a, b)
        end

        def function(_) do
          MyMap.new()
        end
      end
    ]
  end

  test_exercise_analysis "Calling Map.new in function with guards",
    comments: [
      "found a call to Map.new/0 in function/1"
    ] do
    [
      # Single clause function, with a guard. Using import.
      defmodule AssertCallVerification do
        import Map

        def function(b) when is_integer(b) and b > 0 do
          new() |> Map.put(:a, b)
        end
      end,
      # Multiple clause functions with guards, only one of the clauses calls Map.new/0. Using alias.
      defmodule AssertCallVerification do
        alias Map, as: MyMap

        def function(b) when is_atom(b) do
          [:a, b]
        end

        def function(b) when is_integer(b) when b > 0 do
          MyMap.new() |> Map.put(:a, b)
        end

        def function(_) do
          :error
        end
      end,
      # Multiple clause functions with guards, multiple clauses call the function we're looking for.
      defmodule AssertCallVerification do
        def function(b) when is_list(b) do
          Enum.map(b, &(&1 * 2))
        end

        def function(b) when is_integer(b) when b > 0 do
          Map.new() |> Map.put(:a, b)
        end

        def function(b) when is_atom(b) do
          Map.new() |> Map.put(b, 42)
        end
      end
    ]
  end
end
