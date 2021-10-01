defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.ListPrependHead do
  @moduledoc """
  This is an exercise analyzer extension module used for common tests looking for
  usage of `[h] ++ t` instead of `[h | t]` to prepend an item to a list
  """

  alias ElixirAnalyzer.Constants

  defmacro __using__(_opts) do
    quote do
      feature Constants.solution_list_prepend_head() do
        type :informative
        comment Constants.solution_list_prepend_head()
        find :none

        form do
          [_ignore] ++ _ignore
        end
      end
    end
  end
end
