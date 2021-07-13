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

  feature "does not alias or import :math" do
    find :none
    type :essential
    comment ElixirAnalyzer.Constants.square_root_do_not_use_built_in_sqrt()

    form do
      import :math
    end

    form do
      import :math, _ignore
    end

    form do
      alias :math, as: _ignore
    end
  end

  assert_no_call "does not call Float.pow" do
    type :essential
    called_fn module: Float, name: :pow
    comment ElixirAnalyzer.Constants.square_root_do_not_use_built_in_sqrt()
  end

  feature "does not alias or import Float" do
    find :none
    type :essential
    comment ElixirAnalyzer.Constants.square_root_do_not_use_built_in_sqrt()

    form do
      import Float
    end

    form do
      import Float, _ignore
    end

    form do
      alias Float, as: _ignore
    end
  end
end
