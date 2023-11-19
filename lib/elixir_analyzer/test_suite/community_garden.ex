defmodule ElixirAnalyzer.TestSuite.CommunityGarden do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Captains Log
  """
  use ElixirAnalyzer.ExerciseTest
  alias ElixirAnalyzer.Constants

  assert_call "register uses Agent.get_and_update" do
    type :essential
    calling_fn module: CommunityGarden, name: :register
    called_fn module: Agent, name: :get_and_update
    comment Constants.community_garden_use_get_and_update()
  end
end
