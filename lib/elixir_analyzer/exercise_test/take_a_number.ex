defmodule ElixirAnalyzer.ExerciseTest.TakeANumber do
  @dialyzer generated: true
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Take-A-Number
  """

  alias ElixirAnalyzer.Constants

  use ElixirAnalyzer.ExerciseTest

  feature "forbids usage of abstractions like Agent or GenServer" do
    find :none
    on_fail :disapprove
    comment Constants.take_a_number_do_not_use_abstractions()

    form do
      use Agent
    end

    form do
      Agent.start(_ignore)
    end

    form do
      Agent.start(_ignore, _ignore)
    end

    form do
      Agent.start(_ignore, _ignore, _ignore)
    end

    form do
      Agent.start(_ignore, _ignore, _ignore, _ignore)
    end

    form do
      Agent.start_link(_ignore)
    end

    form do
      Agent.start_link(_ignore, _ignore)
    end

    form do
      Agent.start_link(_ignore, _ignore, _ignore)
    end

    form do
      Agent.start_link(_ignore, _ignore, _ignore, _ignore)
    end

    form do
      use GenServer
    end

    form do
      GenServer.start(_ignore, _ignore)
    end

    form do
      GenServer.start(_ignore, _ignore, _ignore)
    end

    form do
      GenServer.start_link(_ignore, _ignore)
    end

    form do
      GenServer.start_link(_ignore, _ignore, _ignore)
    end
  end
end
