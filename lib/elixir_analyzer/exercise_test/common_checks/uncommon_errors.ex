defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.UncommonErrors do
  @moduledoc """
  This is an exercise analyzer extension module used for common tests looking for uncommon errors raised
  """
  alias ElixirAnalyzer.Constants

  defmacro __using__(_opts) do
    quote do
      feature Constants.solution_raise_fn_clause_error() do
        find :none
        type :actionable
        comment Constants.solution_raise_fn_clause_error()

        form do
          raise FunctionClauseError
        end

        form do
          raise %FunctionClauseError{}
        end
      end
    end
  end
end
