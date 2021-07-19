defmodule ElixirAnalyzer.Support.AnalyzerVerification.AssertCall.Erlang do
  @moduledoc """
  This is an exercise analyzer extension module to test the assert_call and assert_no_call 
  macros specifically for using Erlang modules
  """

  use ElixirAnalyzer.ExerciseTest

  assert_call "finds call to :rand.normal function anywhere" do
    type :informational
    called_fn module: :rand, name: :normal
    comment "didn't find a call to :rand.normal anywhere in module"
  end

  assert_call "finds call to :rand.normal in function/0" do
    type :informational
    called_fn module: :rand, name: :normal
    calling_fn module: AssertCallVerification, name: :function
    comment "didn't find a call to :rand.normal/0 in function/0"
  end

  assert_call "find a call to any :rand function from anywhere" do
    type :informational
    called_fn module: :rand, name: :_
    comment "didn't find any call to a :rand function"
  end

  assert_call "finds call to any :rand function in function/0" do
    type :informational
    called_fn module: :rand, name: :_
    calling_fn module: AssertCallVerification, name: :function
    comment "didn't find a call to a :rand function in function/0"
  end

  assert_no_call "does not call :rand.normal function" do
    type :informational
    called_fn module: :rand, name: :normal
    comment "found a call to :rand.normal in module"
  end

  assert_no_call "does not call :rand.normal in specific function" do
    type :informational
    calling_fn module: AssertCallVerification, name: :function
    called_fn module: :rand, name: :normal
    comment "found a call to :rand.normal in function/0"
  end

  assert_no_call "does not call any function from the :rand module" do
    type :informational
    called_fn module: :rand, name: :_
    comment "found a call to :rand in module"
  end

  assert_no_call "does not call any function from the :rand module in specific function" do
    type :informational
    calling_fn module: AssertCallVerification, name: :function
    called_fn module: :rand, name: :_
    comment "found a call to :rand in function/0"
  end
end
