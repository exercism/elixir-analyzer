defmodule ElixirAnalyzer.TestSuite.LogLevel do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Log Level
  """

  use ElixirAnalyzer.ExerciseTest
  alias ElixirAnalyzer.Constants

  assert_call "to_label uses cond/1" do
    type :essential
    comment Constants.log_level_use_cond()
    calling_fn module: LogLevel, name: :to_label
    called_fn name: :cond
  end

  assert_call "alert_recipient uses cond/1" do
    type :essential
    comment Constants.log_level_use_cond()
    calling_fn module: LogLevel, name: :alert_recipient
    called_fn name: :cond
  end
end
