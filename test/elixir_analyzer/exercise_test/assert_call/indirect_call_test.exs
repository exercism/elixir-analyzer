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
      # via helper and an alias
      defmodule AssertCallVerification do
        alias Elixir.Mix.Utils, as: U
        alias :math, as: M

        def main_function() do
          helper("")
          |> do_something()
        end

        def helper(path) do
          U.read_path(path)
          final_function(M.pi())
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
      end,
      # via defdelegate
      defmodule AssertCallVerification do
        def main_function() do
          helper("")
          |> do_something()
        end

        def helper(path) do
          read_path(path)
          final_function(pi())
        end

        defdelegate read_path(path), to: Elixir.Mix.Utils
        defdelegate pi(), to: :math
      end,
      # via defdelegate with renaming
      defmodule AssertCallVerification do
        def main_function() do
          helper("")
          |> do_something()
        end

        def helper(path) do
          rp(path)
          final_function(p())
        end

        defdelegate rp(path), to: Elixir.Mix.Utils, as: :read_path
        defdelegate p(), to: :math, as: :pi
      end,
      # via indirect defdelegate with renaming
      ~S"""
      defmodule Helpers do
        defdelegate do_read_path(path), to: Elixir.Mix.Utils, as: :read_path
        defdelegate pi(), to: :math, as: :pi
      end

      defmodule AssertCallVerification do
        def main_function() do
          helper("")
          |> do_something()
        end

        def helper(path) do
          rp(path)
          final_function(p())
        end

        defdelegate rp(path), to: Helpers, as: :do_read_path
        defdelegate p(), to: Helpers, as: :pi
      end
      """,
      # via defdelegate to same module
      defmodule AssertCallVerification do
        def main_function() do
          helper("")
          |> do_something()
        end

        def helper(path) do
          rp(path)
          final_function(p())
        end

        def do_rp(path) do
          Elixir.Mix.Utils.read_path(path)
        end

        def do_p() do
          :math.pi()
        end

        defdelegate rp(path), to: __MODULE__, as: :do_rp
        defdelegate p(), to: AssertCallVerification, as: :do_p
      end,
      # via defdelegate with aliases on final call
      defmodule AssertCallVerification do
        alias Elixir.Mix.Utils, as: U
        alias :math, as: M

        def main_function() do
          helper("")
          |> do_something()
        end

        def helper(path) do
          read_path(path)
          final_function(pi())
        end

        defdelegate read_path(path), to: U
        defdelegate pi(), to: M
      end,
      # via defdelegate with aliases in intermediate calls
      ~S"""
      defmodule Helpers do
        defdelegate do_read_path(path), to: Elixir.Mix.Utils, as: :read_path
        defdelegate pi(), to: :math, as: :pi
      end

      defmodule AssertCallVerification do
        alias Helpers, as: Hs

        def main_function() do
          helper("")
          |> do_something()
        end

        def helper(path) do
          rp(path)
          final_function(p())
        end

        defdelegate rp(path), to: Hs, as: :do_read_path
        defdelegate p(), to: Hs, as: :pi
      end
      """
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
      end,
      # via defdelegate but to wrong module
      defmodule AssertCallVerification do
        def main_function() do
          helper("")
          |> do_something()
        end

        def helper(path) do
          read_path(path)
          pi()
        end

        defdelegate read_path(path), to: Elixir.Mix.NOTUtils
        defdelegate pi(), to: :not_math
      end,
      # via defdelegate with renaming but to wrong module
      defmodule AssertCallVerification do
        def main_function() do
          helper("")
          |> do_something()
        end

        def helper(path) do
          read_path(path)
          pi()
        end

        defdelegate read_path(path), to: Elixir.NOTMix.Utils, as: :read_path
        defdelegate pi(), to: :not_math, as: :pi
      end,
      # via defdelegate with renaming but to wrong function
      defmodule AssertCallVerification do
        def main_function() do
          helper("")
          |> do_something()
        end

        def helper(path) do
          read_path(path)
          pi()
        end

        defdelegate read_path(path), to: Elixir.Mix.Utils, as: :not_read_path
        defdelegate pi(), to: :math, as: :not_pi
      end
    ]
  end
end
