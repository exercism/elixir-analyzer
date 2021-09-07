# credo:disable-for-this-file Credo.Check.Readability.FunctionNames

defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.UnlessWithElseTest do
  use Credo.Test.Case

  alias ElixirAnalyzer.ExerciseTest.CommonChecks.UnlessWithElse
  alias ElixirAnalyzer.Comment
  alias ElixirAnalyzer.Constants

  test "should NOT report `unless` without an `else` block" do
    code =
      quote do
        defmodule ABC do
          def abc do
            unless allowed? do
              something
            end
          end
        end
      end

    assert UnlessWithElse.run(code) == []
  end

  test "should return an actionable comment with params when an `unless` with `else` block is given" do
    code =
      quote do
        defmodule ABC do
          def abc do
            unless allowed? do
              something
            else
              another_thing
            end
          end
        end
      end

    error_message = [
      {:fail,
       %Comment{
         type: :actionable,
         comment: Constants.solution_unless_with_else()
       }}
    ]

    assert UnlessWithElse.run(code) == error_message
  end
end
