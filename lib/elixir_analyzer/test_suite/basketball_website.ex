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

  assert_no_call "does not use Map" do
    type :essential
    comment Constants.basketball_website_no_map()
    called_fn module: Map, name: :_
  end

  assert_no_call "extract_from_path does not use get_in" do
    type :essential
    comment Constants.basketball_website_get_in()
    called_fn name: :get_in
    calling_fn module: BasketballWebsite, name: :extract_from_path
  end

  assert_call "get_in_path must use get_in" do
    type :essential
    comment Constants.basketball_website_get_in()
    called_fn module: Kernel, name: :get_in
    calling_fn module: BasketballWebsite, name: :get_in_path
  end
end
