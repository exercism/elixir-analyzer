defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.DebugFunctions do
  @moduledoc """
  This is an exercise analyzer extension module used for common tests looking for debugging functions
  """

  alias ElixirAnalyzer.Constants

  defmacro __using__(_opts) do
    quote do
      assert_no_call Constants.solution_debug_functions() do
        type :informative
        comment Constants.solution_debug_functions()
        called_fn module: IO, name: :inspect
      end

      assert_no_call Constants.solution_debug_functions() do
        type :informative
        comment Constants.solution_debug_functions()
        called_fn module: Kernel, name: :dbg
      end
    end
  end
end
