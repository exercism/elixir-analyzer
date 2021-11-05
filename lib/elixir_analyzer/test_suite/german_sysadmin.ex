defmodule ElixirAnalyzer.TestSuite.GermanSysadmin do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise German Sysadmin
  """

  use ElixirAnalyzer.ExerciseTest
  alias ElixirAnalyzer.Constants

  assert_no_call "doesn't convert anything to a string" do
    type :essential
    called_fn name: :to_string
    comment Constants.german_sysadmin_no_string()
  end

  assert_no_call "doesn't convert anything to a charlist" do
    type :essential
    called_fn name: :to_charlist
    comment Constants.german_sysadmin_no_string()
  end

  assert_no_call "doesn't use any string functions" do
    type :essential
    called_fn module: String, name: :_
    comment Constants.german_sysadmin_no_string()
  end

  assert_no_call "doesn't create binaries from character codes" do
    type :essential
    called_fn name: :<<>>
    comment Constants.german_sysadmin_no_string()
  end

  assert_call "using case is required" do
    type :essential
    called_fn name: :case
    comment Constants.german_sysadmin_use_case()
  end

  check_source "does not use integer literals for code points" do
    type :actionable
    comment Constants.solution_no_integer_literal()

    check(source) do
      integers = ["?ß", "?ä", "?ö", "?ü", "?_", "?a", "?z"]
      Enum.all?(integers, &String.contains?(source, &1))
    end
  end
end
