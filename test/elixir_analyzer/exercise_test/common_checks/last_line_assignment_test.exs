defmodule ElixirAnalyzer.Support.AnalyzerVerification.LastLineAssignment do
  use ElixirAnalyzer.ExerciseTest
end

defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.LastLineAssignmentTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.Support.AnalyzerVerification.LastLineAssignment

  alias ElixirAnalyzer.Constants

  test_exercise_analysis "Solutions without a last line assignment",
    comments: [] do
    [
      defmodule MyModule do
        def ok() do
          :ok
        end

        defp two() do
          two = 1 + 1
          two
        end

        defmacro nothing() do
          a = nil

          quote do
            unquote(a)
          end
        end

        defmacrop add_macro() do
          a = 1 + 1

          quote do
            unquote(a)
          end
        end
      end
    ]
  end

  test_exercise_analysis "Solutions with a last line assignment",
    comments: [Constants.solution_last_line_assignment()] do
    [
      defmodule MyModule do
        def ok() do
          a = :ok
        end
      end,
      defmodule MyModule do
        def ok() do
          a = :ok |> Atom.to_string()
        end
      end,
      defmodule MyModule do
        defp two() do
          _a = 1 + 1
        end
      end,
      defmodule MyModule do
        defmacro nothing() do
          a = nil

          quote =
            quote do
              unquote(a)
            end
        end
      end,
      defmodule MyModule do
        defmacrop add_macro() do
          a = 1 + 1

          _quote =
            quote do
              unquote(a)
            end
        end
      end
    ]
  end
end
