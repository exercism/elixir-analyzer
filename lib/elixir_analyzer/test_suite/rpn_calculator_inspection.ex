defmodule ElixirAnalyzer.TestSuite.RpnCalculatorInspection do
  @moduledoc """
  This is an exercise analyzer test suite for the concept exercise rpn-calculator-inspection
  """

  use ElixirAnalyzer.ExerciseTest

  assert_no_call "does not call Process.link" do
    type :essential
    called_fn module: Process, name: :link
    comment ElixirAnalyzer.Constants.rpn_calculator_inspection_use_start_link()
  end

  assert_call "calls Task.start_link" do
    type :essential
    called_fn module: Task, name: :start_link
    comment ElixirAnalyzer.Constants.rpn_calculator_inspection_use_start_link()
    suppress_if "calls spawn_link", :pass
  end

  assert_call "calls spawn_link" do
    type :essential
    called_fn name: :spawn_link
    comment ElixirAnalyzer.Constants.rpn_calculator_inspection_use_start_link()
    suppress_if "calls Task.start_link", :pass
  end
end
