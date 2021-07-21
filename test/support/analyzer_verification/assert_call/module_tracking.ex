defmodule ElixirAnalyzer.Support.AnalyzerVerification.AssertCall.ModuleTracking do
  @moduledoc """
  This is an exercise analyzer extension module to test the assert_call and assert_no_call
  macros specifically from imports and aliases
  """

  use ElixirAnalyzer.ExerciseTest

  assert_call "find a call to Elixir.Mix.Utils.read_path/1 from anywhere" do
    type :informational
    called_fn module: Elixir.Mix.Utils, name: :read_path
    comment "didn't find any call to Elixir.Mix.Utils.read_path/1"
  end


  assert_no_call "didn't call to Elixir.Mix.Utils.read_path/1 from anywhere" do
    type :informational
    called_fn module: Elixir.Mix.Utils, name: :read_path
    comment "found a call to Elixir.Mix.Utils.read_path/1"
  end

end
