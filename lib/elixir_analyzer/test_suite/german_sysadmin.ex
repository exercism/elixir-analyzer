defmodule ElixirAnalyzer.TestSuite.GermanSysadmin do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise German Sysadmin
  """

  use ElixirAnalyzer.ExerciseTest

  assert_no_call "doesn't convert anything to a string" do
    type :essential
    called_fn name: :to_string
    comment ElixirAnalyzer.Constants.german_sysadmin_no_strings()
  end

  assert_no_call "doesn't convert anything to a charlist" do
    type :essential
    called_fn name: :to_charlist
    comment ElixirAnalyzer.Constants.german_sysadmin_no_strings()
  end

  assert_no_call "doesn't use any string functions" do
    type :essential
    called_fn module: String, name: :_
    comment ElixirAnalyzer.Constants.german_sysadmin_no_strings()
  end

  assert_no_call "doesn't create binaries from character codes" do
    type :essential
    called_fn name: :<<>>
    comment ElixirAnalyzer.Constants.german_sysadmin_no_strings()
  end

  assert_call "using case is required" do
    type :essential
    called_fn name: :case
    comment ElixirAnalyzer.Constants.german_sysadmin_use_case()
  end
end
