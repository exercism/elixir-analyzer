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
        defmodule UnrelateInternaldModule do
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
      end
    ]
  end
end
