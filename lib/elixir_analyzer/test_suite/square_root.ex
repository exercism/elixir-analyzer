defmodule ElixirAnalyzer.TestSuite.SquareRoot do
  @moduledoc """
  This is an exercise analyzer extension module for the practice exercise SquareRoot
  """

  use ElixirAnalyzer.ExerciseTest
  alias ElixirAnalyzer.Constants

  assert_no_call "does not call :math.sqrt" do
    type :essential
    called_fn module: :math, name: :sqrt
    comment Constants.square_root_do_not_use_built_in_sqrt()
  end

  assert_no_call "does not call :math.pow" do
    type :essential
    called_fn module: :math, name: :pow
    comment Constants.square_root_do_not_use_built_in_sqrt()
  end

  assert_no_call "does not call Float.pow" do
    type :essential
    called_fn module: Float, name: :pow
    comment Constants.square_root_do_not_use_built_in_sqrt()
  end

  assert_no_call "do not use **" do
    type :essential
    called_fn module: Kernel, name: :**
    comment Constants.square_root_do_not_use_built_in_sqrt()
  end
end
