defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.DebugFunctions do
  @moduledoc """
  This is an exercise analyzer extension module used for common tests looking for debugging functions
  """

  defmacro __using__(_opts) do
    quote do
      assert_no_call unquote(ElixirAnalyzer.Constants.solution_debug_functions()) do
        type :informational
        comment ElixirAnalyzer.Constants.solution_debug_functions()
        called_fn module: IO, name: :inspect
      end
    end
  end
end
