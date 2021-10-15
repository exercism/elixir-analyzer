defmodule ElixirAnalyzer.Support.AnalyzerVerification.AssertCall.MultipleClauseFunctions do
  @moduledoc """
  This is an exercise analyzer extension module to test the assert_call and assert_no_call
  macros on functions with multiple clauses, with and without guards.
  """

  use ElixirAnalyzer.ExerciseTest

  assert_call "finds call to Map.new/0 in function/1" do
    type :informative
    called_fn module: Map, name: :new
    calling_fn module: AssertCallVerification, name: :function
    comment "didn't find a call to Map.new/0 in function/1"
  end

  assert_no_call "does not find call to Map.new/0 in function/1" do
    type :informative
    called_fn module: Map, name: :new
    calling_fn module: AssertCallVerification, name: :function
    comment "found a call to Map.new/0 in function/1"
  end
end
