defmodule ElixirAnalyzer.TestSuite.BirdCount do
  @dialyzer generated: true
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Bird Count
  """

  alias ElixirAnalyzer.Constants

  use ElixirAnalyzer.ExerciseTest

  not_allowed_functions =
    [Enum, List, Stream]
    |> Enum.flat_map(fn module ->
      Enum.map(module.module_info(:exports), fn {fun, _arity} -> {module, fun} end)
    end)

  Enum.map(not_allowed_functions, fn {module, function} ->
    assert_no_call "does not call #{module}.#{function}" do
      type :essential
      called_fn module: module, name: function
      comment Constants.bird_count_use_recursion()
    end
  end)

  # TODO: list comprehensions
end
