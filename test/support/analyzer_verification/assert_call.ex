defmodule ElixirAnalyzer.Support.AnalyzerVerification.AssertCall do
  @dialyzer generated: true
  @moduledoc """
  This is an exercise analyzer extension module to test the assert_call macro
  """

  use ElixirAnalyzer.ExerciseTest

  assert_call "finds call to local helper function" do
    type :informational
    called_fn name: :helper
    comment "didn't find a local call to helper/0"
  end

  assert_call "finds call to private local helper function" do
    type :informational
    called_fn name: :private_helper
    comment "didn't find a local call to private_helper/0"
  end

  assert_call "finds call to local helper function within function" do
    type :informational
    calling_fn module: AssertCallVerification, name: :function
    called_fn name: :helper
    comment "didn't find a local call to helper/0 within function/0"
  end

  assert_call "finds call to private local helper function within function" do
    type :informational
    calling_fn module: AssertCallVerification, name: :function
    called_fn name: :private_helper
    comment "didn't find a local call to private_helper/0 within function/0"
  end

  assert_call "finds call to IO.puts anywhere" do
    type :informational
    called_fn module: IO, name: :puts
    comment "didn't find a call to IO.puts/1 anywhere in solution"
  end

  assert_call "finds call to IO.puts in function/0" do
    type :informational
    called_fn module: IO, name: :puts
    calling_fn module: AssertCallVerification, name: :function
    comment "didn't find a call to IO.puts/1 in function/0"
  end

  assert_call "finds call to any List function anywhere" do
    type :informational
    called_fn module: List, name: :*
    comment "didn't find a call to a List function"
  end

  assert_call "finds call to any List function anywhere" do
    type :informational
    called_fn module: List, name: :*
    calling_fn module: AssertCallVerification, name: :function
    comment "didn't find a call to a List function in function/0"
  end
end
