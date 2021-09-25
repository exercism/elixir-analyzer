defmodule ElixirAnalyzer.TestSuite.BoutiqueSuggestions do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Boutique Suggestions
  """

  use ElixirAnalyzer.ExerciseTest
  alias ElixirAnalyzer.Constants

  assert_call "uses list comprehensions" do
    type :essential
    called_fn name: :for
    comment Constants.boutique_suggestions_use_list_comprehensions()
  end

  assert_no_call "does not call any Enum functions" do
    type :essential
    called_fn module: Enum, name: :_
    comment Constants.boutique_suggestions_use_list_comprehensions()
  end

  assert_no_call "does not call any Stream functions" do
    type :essential
    called_fn module: Stream, name: :_
    comment Constants.boutique_suggestions_use_list_comprehensions()
  end

  assert_no_call "does not call any List functions" do
    type :essential
    called_fn module: List, name: :_
    comment Constants.boutique_suggestions_use_list_comprehensions()
  end
end
