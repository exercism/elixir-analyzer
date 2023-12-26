defmodule ElixirAnalyzer.Support.AnalyzerVerification.AssertCall.Kernel do
  @moduledoc """
  This is an exercise analyzer extension module to test the assert_call and assert_no_call
  macros specifically for finding Kernel functions
  """

  use ElixirAnalyzer.ExerciseTest

  assert_call "finds call to Kernel.dbg/0 with explicit module" do
    type :informative
    called_fn module: Kernel, name: :dbg
    comment "didn't find a call to Kernel.dbg/0"
  end

  assert_call "finds call to Kernel.dbg/0 without module" do
    type :informative
    called_fn name: :dbg
    comment "didn't find a call to dbg/0"
  end

  assert_call "finds call to Kernel.self/0 with explicit module" do
    type :informative
    called_fn module: Kernel, name: :self
    comment "didn't find a call to Kernel.self/0"
  end

  assert_call "finds call to Kernel.self/0 without module" do
    type :informative
    called_fn name: :self
    comment "didn't find a call to self/0"
  end

  assert_call "finds call to Kernel.SpecialForms.<<>>/1 without module" do
    type :informative
    called_fn name: :<<>>
    comment "didn't find a call to <<>>/1"
  end
end
