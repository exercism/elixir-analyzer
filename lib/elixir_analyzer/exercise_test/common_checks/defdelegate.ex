defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.Defdelegate do
  @moduledoc """
  This is an exercise analyzer extension module used for common tests looking for
  usage of defdelegate.
  """

  alias ElixirAnalyzer.Constants

  defmacro __using__(_opts) do
    quote do
      assert_no_call Constants.solution_defdelegate() do
        type :actionable
        comment Constants.solution_defdelegate()
        called_fn name: :defdelegate
      end
    end
  end
end
