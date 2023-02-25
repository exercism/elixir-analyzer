defmodule ElixirAnalyzer.TestSuite.RpnCalculator do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise rpn-calculator
  """

  alias ElixirAnalyzer.Constants
  use ElixirAnalyzer.ExerciseTest, suppress_tests: [Constants.solution_no_rescue()]
end
