defmodule ElixirAnalyzer.TestSuite.AnalyzerVerification.AssertCall do
  @dialyzer generated: true
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Pacman Rules
  """

  use ElixirAnalyzer.ExerciseTest

  assert_call "finds call to local helper function" do
    type :informational
    called_fn :local, &AssertCallVerification.helper/0
    comment "didn't find a local call to helper/0"
  end

  assert_call "finds call to private local helper function" do
    type :informational
    called_fn :local, &AssertCallVerification.private_helper/0
    comment "didn't find a local call to private_helper/0"
  end

  assert_call "finds call to local helper function within function" do
    type :informational
    calling_fn :global, &AssertCallVerification.function/0
    called_fn :local, &AssertCallVerification.helper/0
    comment "didn't find a local call to helper/0 within function/0"
  end

  assert_call "finds call to private local helper function within function" do
    type :informational
    calling_fn :global, &AssertCallVerification.function/0
    called_fn :local, &AssertCallVerification.private_helper/0
    comment "didn't find a local call to private_helper/0 within function"
  end
end
