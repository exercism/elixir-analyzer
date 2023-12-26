defmodule ElixirAnalyzer.Support.AnalyzerVerification.AssertCall.FunctionHeadCall do
  @moduledoc """
  This is an exercise analyzer extension module to test assert_call calling a function from
    outside any function/macro bodies.
  """

  use ElixirAnalyzer.ExerciseTest

  assert_call "find a call to Kernel.>/2" do
    type :informative
    called_fn module: Kernel, name: :>
    comment "didn't find any call to Kernel.>/2 from anywhere"
  end

  assert_call "find a call to Kernel.is_integer/1 from main_function" do
    type :informative
    called_fn module: Kernel, name: :is_integer
    calling_fn module: AssertCallVerification, name: :main_function
    comment "didn't find any call to Kernel.is_integer/1 from main_function/1"
  end

  assert_call "find a call to |/2 from main_function" do
    type :informative
    called_fn name: :|
    calling_fn module: AssertCallVerification, name: :main_function
    comment "didn't find any call to |/2 from main_function/1"
  end

  assert_call "find a call to Kernel.@/1 from main_function" do
    type :informative
    called_fn module: Kernel, name: :@
    calling_fn module: AssertCallVerification, name: :main_function
    comment "didn't find any call to Kernel.@/1 from main_function/1"
  end
end
