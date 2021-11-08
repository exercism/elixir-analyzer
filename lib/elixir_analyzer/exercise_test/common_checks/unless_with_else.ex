defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.UnlessWithElse do
  @moduledoc """
  Reports the first occurence of unless/2 macro used with else.
  """
  alias ElixirAnalyzer.Constants

  defmacro __using__(_opts) do
    quote do
      feature Constants.solution_unless_with_else() do
        type :informative
        find :none
        comment Constants.solution_unless_with_else()

        form do
          unless _ignore do
            _ignore
          else
            _ignore
          end
        end
      end
    end
  end
end
