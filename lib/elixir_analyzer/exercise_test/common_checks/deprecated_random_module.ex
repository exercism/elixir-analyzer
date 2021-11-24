defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.DeprecatedRandomModule do
  @moduledoc """
  Asserts the deprecated Erlang module :random is not used
  """
  alias ElixirAnalyzer.Constants

  defmacro __using__(_opts) do
    quote do
      assert_no_call Constants.solution_deprecated_random_module() do
        type :actionable
        comment Constants.solution_deprecated_random_module()
        called_fn module: :random, name: :_
      end
    end
  end
end
