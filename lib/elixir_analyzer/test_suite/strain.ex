defmodule ElixirAnalyzer.TestSuite.Strain do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Strain
  """

  use ElixirAnalyzer.ExerciseTest

  assert_no_call "does not call Enum.filter/2" do
    type :essential
    called_fn module: Enum, name: :filter
    comment ElixirAnalyzer.Constants.strain_use_recursion()
  end

  assert_no_call "does not call Enum.reject/2" do
    type :essential
    called_fn module: Enum, name: :reject
    comment ElixirAnalyzer.Constants.strain_use_recursion()
  end

  assert_no_call "does not call Stream.filter/2" do
    type :essential
    called_fn module: Stream, name: :filter
    comment ElixirAnalyzer.Constants.strain_use_recursion()
  end

  assert_no_call "does not call Stream.reject/2" do
    type :essential
    called_fn module: Stream, name: :reject
    comment ElixirAnalyzer.Constants.strain_use_recursion()
  end

  assert_no_call "doesn't use list comprehensions" do
    type :essential
    called_fn name: :for
    comment ElixirAnalyzer.Constants.strain_use_recursion()
  end
end
