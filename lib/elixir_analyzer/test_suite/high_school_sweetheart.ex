defmodule ElixirAnalyzer.TestSuite.HighSchoolSweetheart do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise HighSchoolSweetheart
  """

  alias ElixirAnalyzer.Constants

  use ElixirAnalyzer.ExerciseTest

  assert_call "initial/1 reuses first_letter/1" do
    type :actionable
    calling_fn module: HighSchoolSweetheart, name: :initial
    called_fn name: :first_letter
    comment Constants.high_school_sweetheart_function_reuse()
  end

  assert_call "initials/1 reuses initial/1" do
    type :actionable
    calling_fn module: HighSchoolSweetheart, name: :initials
    called_fn name: :initial
    comment Constants.high_school_sweetheart_function_reuse()
  end

  assert_call "pair/1 reuses initials/1" do
    type :actionable
    calling_fn module: HighSchoolSweetheart, name: :pair
    called_fn name: :initials
    comment Constants.high_school_sweetheart_function_reuse()
  end
end
