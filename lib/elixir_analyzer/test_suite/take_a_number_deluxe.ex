defmodule ElixirAnalyzer.TestSuite.TakeANumberDeluxe do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise rpg-character-sheet
  """

  alias ElixirAnalyzer.Constants

  use ElixirAnalyzer.ExerciseTest,
    # this is temporary until we include editor files in compilation
    suppress_tests: [Constants.solution_compiler_warnings()]

  feature "uses GenServer" do
    type :actionable
    find :any
    comment Constants.take_a_number_deluxe_use_genserver()

    form do
      use GenServer
    end
  end

  feature "uses @impl GenServer" do
    type :actionable
    find :any
    comment Constants.take_a_number_deluxe_annotate_impl_genserver()

    form do
      @impl GenServer
    end
  end
end
