defmodule ElixirAnalyzer.TestSuite.RpnCalculatorOutput do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise rpn-calculator-output
  """

  use ElixirAnalyzer.ExerciseTest
  alias ElixirAnalyzer.Constants

  feature "uses all of try-rescue-else-after" do
    type :essential
    find :all
    depth 2
    comment Constants.rpn_calculator_output_try_rescue_else_after()

    form do
      try do
        _ignore
      rescue
        _ignore
      else
        _ignore
      after
        _ignore
      end
    end
  end

  feature "open must be before try" do
    type :essential
    find :all
    depth 2
    comment Constants.rpn_calculator_output_open_before_try()

    form do
      _block_includes do
        _ignore = _ignore.open(_ignore)
        try _ignore
      end
    end
  end

  feature "write must be in the try block" do
    type :essential
    find :all
    depth 2
    comment Constants.rpn_calculator_output_write_in_try()

    form do
      try do
        _block_includes do
          IO.write(_ignore, _ignore)
        end
      rescue
        _ignore
      else
        _ignore
      after
        _ignore
      end
    end
  end

  feature "final result must be in the else block" do
    type :essential
    find :all
    depth 2
    comment Constants.rpn_calculator_output_output_in_else()

    form do
      try do
        _ignore
      rescue
        _ignore
      else
        _block_includes do
          _ignore -> {:ok, _ignore}
        end
      after
        _ignore
      end
    end
  end

  feature "close must be in the after block" do
    type :essential
    find :all
    depth 2
    comment Constants.rpn_calculator_output_close_in_after()

    form do
      try do
        _ignore
      rescue
        _ignore
      else
        _ignore
      after
        _block_includes do
          _ignore.close(_ignore)
        end
      end
    end
  end
end
