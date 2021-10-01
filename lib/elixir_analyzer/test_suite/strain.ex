defmodule ElixirAnalyzer.TestSuite.Strain do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Strain
  """

  use ElixirAnalyzer.ExerciseTest
  alias ElixirAnalyzer.Constants

  assert_no_call "does not call Enum.filter/2" do
    type :essential
    called_fn module: Enum, name: :filter
    comment Constants.strain_use_recursion()
  end

  assert_no_call "does not call Enum.reject/2" do
    type :essential
    called_fn module: Enum, name: :reject
    comment Constants.strain_use_recursion()
  end

  assert_no_call "does not call Stream.filter/2" do
    type :essential
    called_fn module: Stream, name: :filter
    comment Constants.strain_use_recursion()
  end

  assert_no_call "does not call Stream.reject/2" do
    type :essential
    called_fn module: Stream, name: :reject
    comment Constants.strain_use_recursion()
  end

  assert_no_call "doesn't use list comprehensions" do
    type :essential
    called_fn name: :for
    comment Constants.strain_use_recursion()
  end
end
