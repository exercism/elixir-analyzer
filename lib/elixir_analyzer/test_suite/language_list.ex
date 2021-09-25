defmodule ElixirAnalyzer.TestSuite.LanguageList do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Language List
  """

  use ElixirAnalyzer.ExerciseTest
  alias ElixirAnalyzer.Constants

  assert_no_call "does not call any Enum functions" do
    type :essential
    called_fn module: Enum, name: :_
    comment Constants.language_list_do_not_use_enum()
  end
end
