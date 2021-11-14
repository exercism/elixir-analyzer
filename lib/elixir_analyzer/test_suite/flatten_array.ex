defmodule ElixirAnalyzer.TestSuite.FlattenArray do
  @moduledoc """
  This is an exercise analyzer extension module for the practice exercise Flatten Array
  """

  use ElixirAnalyzer.ExerciseTest
  alias ElixirAnalyzer.Constants

  assert_no_call "does not call any Enum functions" do
    type :essential
    called_fn module: Enum, name: :_
    comment Constants.flatten_array_use_recursion()
  end

  assert_no_call "does not call any Stream functions" do
    type :essential
    called_fn module: Stream, name: :_
    comment Constants.flatten_array_use_recursion()
  end

  assert_no_call "does not call any List functions" do
    type :essential
    called_fn module: List, name: :_
    comment Constants.flatten_array_use_recursion()
  end

  assert_no_call "doesn't use list comprehensions" do
    type :essential
    called_fn name: :for
    comment Constants.flatten_array_use_recursion()
  end
end
