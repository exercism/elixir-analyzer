defmodule ElixirAnalyzer.Support.AnalyzerVerification.AssertCall.ModuleLevelCall do
  @moduledoc """
  This is an exercise analyzer extension module to test assert_call calling a function from
    outside any function/macro bodies.
  """

  use ElixirAnalyzer.ExerciseTest

  assert_call "find a call to Enum.map" do
    type :informative
    called_fn module: Enum, name: :map
    comment "didn't find any call to Enum.map/2 from anywhere"
  end

  assert_call "find a call to List.to_tuple from main_function" do
    type :informative
    called_fn module: List, name: :to_tuple
    calling_fn module: AssertCallVerification, name: :main_function
    comment "didn't find any call to List.to_tuple/1 from main_function/0"
  end
end
