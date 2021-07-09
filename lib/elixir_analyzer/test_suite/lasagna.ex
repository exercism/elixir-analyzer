defmodule ElixirAnalyzer.TestSuite.Lasagna do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Lasagna
  """

  use ElixirAnalyzer.ExerciseTest

  assert_call "remaining minutes in oven are calculated based on expected minutes in oven" do
    type :actionable
    calling_fn module: Lasagna, name: :remaining_minutes_in_oven
    called_fn name: :expected_minutes_in_oven
    comment ElixirAnalyzer.Constants.lasagna_function_reuse()
  end

  assert_call "total time in minutes is calculated based on preparation time in minutes" do
    type :actionable
    calling_fn module: Lasagna, name: :total_time_in_minutes
    called_fn name: :preparation_time_in_minutes
    comment ElixirAnalyzer.Constants.lasagna_function_reuse()
  end
end
