defmodule ElixirAnalyzer.TestSuite.SquareRoot do
  @moduledoc """
  This is an exercise analyzer extension module for the practice exercise SquareRoot
  """

  use ElixirAnalyzer.ExerciseTest

  assert_no_call "does not call :math.sqrt" do
    type :essential
    called_fn module: :math, name: :sqrt
    comment ElixirAnalyzer.Constants.square_root_do_not_use_built_in_sqrt()
  end

  assert_no_call "does not call :math.pow" do
    type :essential
    called_fn module: :math, name: :pow
    comment ElixirAnalyzer.Constants.square_root_do_not_use_built_in_sqrt()
  end

  assert_no_call "does not call Float.pow" do
    type :essential
    called_fn module: Float, name: :pow
    comment ElixirAnalyzer.Constants.square_root_do_not_use_built_in_sqrt()
  end
end
