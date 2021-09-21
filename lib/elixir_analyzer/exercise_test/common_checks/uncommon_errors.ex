defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.UncommonErrors do
  @moduledoc """
  This is an exercise analyzer extension module used for common tests looking for uncommon errors raised
  """

  defmacro __using__(_opts) do
    quote do
      feature "raises function clause error" do
        find :none
        type :actionable
        comment ElixirAnalyzer.Constants.solution_raise_fn_clause_error()

        form do
          raise FunctionClauseError
        end
      end
    end
  end
end
