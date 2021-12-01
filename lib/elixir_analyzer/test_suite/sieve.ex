defmodule ElixirAnalyzer.TestSuite.Sieve do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Sieve
  """

  use ElixirAnalyzer.ExerciseTest
  alias ElixirAnalyzer.Constants

  assert_no_call "does not call rem/2" do
    type :essential
    comment Constants.sieve_do_not_use_div_rem()
    called_fn module: Kernel, name: :rem
  end

  assert_no_call "does not call div/2" do
    type :essential
    comment Constants.sieve_do_not_use_div_rem()
    called_fn module: Kernel, name: :div
  end

  assert_no_call "does not call Kernel.//2" do
    type :essential
    comment Constants.sieve_do_not_use_div_rem()
    called_fn module: Kernel, name: :/
  end

  assert_no_call "does not call Integer module" do
    type :essential
    comment Constants.sieve_do_not_use_div_rem()
    called_fn module: Integer, name: :_
  end

  assert_no_call "does not call Float module" do
    type :essential
    comment Constants.sieve_do_not_use_div_rem()
    called_fn module: Float, name: :_
  end

  assert_no_call "does not call :math module" do
    type :essential
    comment Constants.sieve_do_not_use_div_rem()
    called_fn module: :math, name: :_
  end
end
