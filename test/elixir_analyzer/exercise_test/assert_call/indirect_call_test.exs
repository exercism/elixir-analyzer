defmodule ElixirAnalyzer.ExerciseTest.AssertCall.IndirectCallTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.Support.AnalyzerVerification.AssertCall.IndirectCall

  test_exercise_analysis "Calling functions from main_function/0",
    comments_exclude: [
      "didn't find any call to Elixir.Mix.Utils.read_path/1 from main_function/0",
      "didn't find any call to :math.pi from main_function/0",
      "didn't find any call to final_function/1 from main_function/0"
    ] do
    [
      defmodule AssertCallVerification do
        def main_function() do
          file = Elixir.Mix.Utils.read_path("")
          do_something(file)
          final_function(:math.pi())
        end
      end,
      # via helper
      defmodule AssertCallVerification do
        def main_function() do
          helper("")
          |> do_something()
        end

        def helper(path) do
          Elixir.Mix.Utils.read_path(path)
          final_function(:math.pi())
        end
      end,
      # via two helpers
      defmodule AssertCallVerification do
        def main_function() do
          helper("")
          |> do_something()
        end

        def helper(path) do
          helper_2(path)
        end

        def helper_2(path) do
          Elixir.Mix.Utils.read_path(path)

          :math.pi()
          |> final_function
        end
      end,
      # via three helpers
      defmodule AssertCallVerification do
        def main_function() do
          helper("")
          |> do_something()
        end

        def helper(path) do
          helper_2(path)
        end

        def helper_2(path) do
          helper_3(path)
        end

        def helper_3(path) do
          Elixir.Mix.Utils.read_path(path)
          final_function(:math.pi())
        end
      end,
      # via two helpers unnecessarily referencing the module in local calls
      defmodule AssertCallVerification do
        def main_function() do
          AssertCallVerification.helper("")
          |> do_something()
        end

        def helper(path) do
          __MODULE__.helper_2(path)
        end

        def helper_2(path) do
          Elixir.Mix.Utils.read_path(path)

          :math.pi()
          |> AssertCallVerification.final_function()
        end
      end,
      # Full path for the helper function
      defmodule AssertCallVerification do
        def main_function() do
          AssertCallVerification.helper("")
          |> do_something()
        end

        def helper(path) do
          Elixir.Mix.Utils.read_path(path)
          final_function(:math.pi())
        end
      end,
      # __MODULE__ for the helper function
      defmodule AssertCallVerification do
        def main_function() do
          __MODULE__.helper("")
          |> do_something()
        end

        def helper(path) do
          Elixir.Mix.Utils.read_path(path)
          final_function(:math.pi())
        end
      end,
      # call without parentheses at the end of a pipe works
      # Using a sigil because mix format will add parentheses: __MODULE__.helper()
      ~S"""
      defmodule AssertCallVerification do
        def main_function do
          :ok
          |> __MODULE__.helper
          |> do_something
        end

        def helper do
          :ok |> Elixir.Mix.Utils.read_path
          :ok |> :math.pi
          :ok |> final_function
        end
      end
      """,
      # call without parentheses inside of a pipe works
      ~S"""
      defmodule AssertCallVerification do
        def main_function do
          :ok
          |> __MODULE__.helper
          |> do_something
          |> double_check
        end

        def helper do
          :ok
          |> Elixir.Mix.Utils.read_path
          |> :math.pi
          |> final_function
          |> check
        end
      end
      """,
      # call without parentheses works inside of pipe calls or with an explicit module
      ~S"""
      defmodule AssertCallVerification do
        def main_function do
          __MODULE__.helper
          |> do_something
        end

        def helper do
          Elixir.Mix.Utils.read_path
          :math.pi |> final_function
        end
      end
      """,
      # call helper function via captured function
      defmodule AssertCallVerification do
        def main_function do
          :ok
          |> then(&helper/0)
          |> do_something
        end

        def helper do
          Elixir.Mix.Utils.read_path()
          :math.pi() |> final_function
        end
      end,
      # helper function and target function in captured notation
      defmodule AssertCallVerification do
        def main_function do
          :ok
          |> then(&helper/0)
          |> do_something
        end

        def helper do
          Elixir.Mix.Utils.read_path()
          :math.pi() |> then(&final_function/1)
        end
      end
    ]
  end

  test_exercise_analysis "Not calling functions from main_function/0",
    comments_include: [
      "didn't find any call to Elixir.Mix.Utils.read_path/1 from main_function/0",
      "didn't find any call to :math.pi from main_function/0",
      "didn't find any call to final_function/1 from main_function/0"
    ] do
    [
      defmodule AssertCallVerification do
        def main_function() do
        end
      end,
      # recursion is safe
      defmodule AssertCallVerification do
        def main_function() do
          :ok
          |> main_function()
          |> main_function()
          |> do_something()
        end
      end,
      defmodule AssertCallVerification do
        def main_function() do
        end

        def unrelated_function() do
          Elixir.Mix.Utils.read_path(path)
          final_function(:math.pi())
        end
      end,
      defmodule AssertCallVerification do
        # Internal modules don't fool assert_call
        defmodule UnrelatedInternalModule do
          def main_function() do
            helper("")
            |> do_something()
          end

          def helper(path) do
            Elixir.Mix.Utils.read_path(path)
            final_function(:math.pi())
          end
        end

        def main_function() do
        end
      end,
      # function without parentheses doesn't get recognized (but compiler warning gets triggered)
      defmodule AssertCallVerification do
        def main_function() do
          helper(".")
        end

        def helper(path) do
          final_function
        end
      end
    ]
  end
end
