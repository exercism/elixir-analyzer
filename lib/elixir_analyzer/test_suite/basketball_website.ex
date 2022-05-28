defmodule ElixirAnalyzer.TestSuite.BasketballWebsite do
  alias ElixirAnalyzer.Constants
  use ElixirAnalyzer.ExerciseTest

  feature "does not handle nil explicitly" do
    type :actionable
    find :none
    comment Constants.basketball_website_no_explicit_nil()

    form do
      nil
    end
  end
end
