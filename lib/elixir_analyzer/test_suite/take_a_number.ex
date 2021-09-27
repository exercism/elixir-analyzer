defmodule ElixirAnalyzer.TestSuite.TakeANumber do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Take-A-Number
  """

  alias ElixirAnalyzer.Constants

  use ElixirAnalyzer.ExerciseTest

  feature "forbids usage of abstractions like Agent or GenServer" do
    find :none
    type :essential
    comment Constants.take_a_number_do_not_use_abstractions()

    form do
      use Agent
    end

    form do
      use GenServer
    end
  end

  assert_no_call "doesn't call any Agent functions" do
    type :essential
    called_fn module: Agent, name: :_
    comment Constants.take_a_number_do_not_use_abstractions()
  end

  assert_no_call "doesn't call any GenServer functions" do
    type :essential
    called_fn module: GenServer, name: :_
    comment Constants.take_a_number_do_not_use_abstractions()
  end
end
