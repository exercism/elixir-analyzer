defmodule ElixirAnalyzer.TestSuite.NameBadge do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise NameBadge
  """

  use ElixirAnalyzer.ExerciseTest
  alias ElixirAnalyzer.Constants

  feature "Use an if macro" do
    find :any
    type :essential
    comment Constants.name_badge_use_if()

    form do
      if(_ignore, do: _ignore)
    end

    form do
      if(_ignore, do: _ignore, else: _ignore)
    end
  end
end
