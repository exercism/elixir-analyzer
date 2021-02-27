defmodule ElixirAnalyzer.TestSuite.PacmanRules do
  @dialyzer generated: true
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Pacman Rules
  """

  alias ElixirAnalyzer.Constants

  use ElixirAnalyzer.ExerciseTest

  feature "requires using strictly boolean operators" do
    find :none
    type :essential
    comment Constants.pacman_rules_use_strictly_boolean_operators()

    form do
      _ignore && _ignore
    end

    form do
      Kernel.&&(_ignore, _ignore)
    end

    form do
      _ignore || _ignore
    end

    form do
      Kernel.||(_ignore, _ignore)
    end

    form do
      !_ignore
    end

    form do
      Kernel.!(_ignore)
    end
  end
end
