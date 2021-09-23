defmodule ElixirAnalyzer.TestSuite.Leap do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Leap
  """

  use ElixirAnalyzer.ExerciseTest

  assert_no_call "does not call any functions from :calendar Erlang module" do
    type :essential
    called_fn module: :calendar, name: :_
    comment ElixirAnalyzer.Constants.leap_erlang_calendar()
  end
end
