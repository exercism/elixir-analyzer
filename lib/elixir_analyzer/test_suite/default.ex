defmodule ElixirAnalyzer.TestSuite.Default do
  @moduledoc """
  This is the default exercise analyzer extension module.

  It will be run for any exercise submission that doesn't have its own extension module.
  It's empty, which means it will only run the common checks.
  """

  use ElixirAnalyzer.ExerciseTest
end
