defmodule ElixirAnalyzer.TestSuite.WineCellar do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Wine Cellar
  """

  use ElixirAnalyzer.ExerciseTest
  alias ElixirAnalyzer.Constants

  assert_call "uses Keyword.get_values/2 to filter by color" do
    type :essential
    called_fn module: Keyword, name: :get_values
    comment Constants.wine_cellar_use_keyword_get_values()
  end
end
