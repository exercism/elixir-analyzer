defmodule ElixirAnalyzer.Support.AnalyzerVerification.AssertNoCall do
  @moduledoc """
  This is an exercise analyzer extension module to test the assert_call macro
  """

  use ElixirAnalyzer.ExerciseTest

  assert_no_call "does not call local function" do
    type :informative
    called_fn name: :helper
    comment "found a local call to helper/0"
  end

  assert_no_call "does not call local function from specific function" do
    type :informative
    calling_fn module: AssertNoCallVerification, name: :helper
    called_fn name: :private_helper
    comment "found a local call to private_helper/0 from helper/0"
  end

  assert_no_call "does not call other Enum.map function" do
    type :informative
    called_fn module: Enum, name: :map
    comment "found a call to Enum.map in solution"
  end

  assert_no_call "does not call other Atom.to_string in specific function" do
    type :informative
    calling_fn module: AssertNoCallVerification, name: :helper
    called_fn module: Atom, name: :to_string
    comment "found a call to Atom.to_string/1 in helper/0 function in solution"
  end

  assert_no_call "does not call any function from List module" do
    type :informative
    called_fn module: List, name: :_
    comment "don't call List module functions"
  end

  assert_no_call "does not call any function from AlternativeList module" do
    type :informative
    called_fn module: AlternativeList, name: :_
    comment "don't call AlternativeList module functions"
    suppress_if "does not call any function from List module", :fail
  end
end
