defmodule ElixirAnalyzer.Support.AnalyzerVerification.AssertCall.IndirectCall do
  @moduledoc """
  This is an exercise analyzer extension module to test assert_call calling a function from
  a calling function via helper functions
  """

  use ElixirAnalyzer.ExerciseTest

  assert_call "find a call to Elixir.Mix.Utils.read_path/1 from main_function/0" do
    type :informative
    called_fn module: Elixir.Mix.Utils, name: :read_path
    calling_fn module: AssertCallVerification, name: :main_function
    comment "didn't find any call to Elixir.Mix.Utils.read_path/1 from main_function/0"
  end

  assert_call "find a call to :math.pi from main_function/0" do
    type :informative
    called_fn module: :math, name: :pi
    calling_fn module: AssertCallVerification, name: :main_function
    comment "didn't find any call to :math.pi from main_function/0"
  end

  assert_call "find a call to final_function/1 from main_function/0" do
    type :informative
    called_fn name: :final_function
    calling_fn module: AssertCallVerification, name: :main_function
    comment "didn't find any call to final_function/1 from main_function/0"
  end
end
