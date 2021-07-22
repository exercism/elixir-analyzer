defmodule ElixirAnalyzer.TestSuite.Accumulate do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Accumulate
  """

  use ElixirAnalyzer.ExerciseTest

  assert_no_call "does not call any Enum functions" do
    type :essential
    called_fn module: Enum, name: :_
    comment ElixirAnalyzer.Constants.accumulate_use_recursion()
  end

  assert_no_call "does not call any Stream functions" do
    type :essential
    called_fn module: Stream, name: :_
    comment ElixirAnalyzer.Constants.accumulate_use_recursion()
  end

  assert_no_call "does not call any List functions" do
    type :essential
    called_fn module: List, name: :_
    comment ElixirAnalyzer.Constants.accumulate_use_recursion()
  end

  assert_no_call "doesn't use list comprehensions" do
    type :essential
    called_fn name: :for
    comment ElixirAnalyzer.Constants.accumulate_use_recursion()
  end
end
