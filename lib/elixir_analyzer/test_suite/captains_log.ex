defmodule ElixirAnalyzer.TestSuite.CaptainsLog do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Captains Log
  """
  use ElixirAnalyzer.ExerciseTest
  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Source

  assert_call "random_planet_class uses Enum.random" do
    type :essential
    calling_fn module: CaptainsLog, name: :random_planet_class
    called_fn module: Enum, name: :random
    comment Constants.captains_log_use_enum_random()
  end

  assert_call "random_ship_registry_number uses Enum.random" do
    type :essential
    calling_fn module: CaptainsLog, name: :random_ship_registry_number
    called_fn module: Enum, name: :random
    comment Constants.captains_log_use_enum_random()
  end

  assert_no_call "random_stardate does not use Enum.random" do
    type :essential
    calling_fn module: CaptainsLog, name: :random_stardate
    called_fn module: Enum, name: :random
    comment Constants.captains_log_do_not_use_enum_random()
  end

  assert_no_call "random_stardate does not use :rand.uniform_real" do
    type :essential
    calling_fn module: CaptainsLog, name: :random_stardate
    called_fn module: :rand, name: :uniform_real
    comment Constants.captains_log_do_not_use_rand_uniform_real()
  end

  assert_call "random_stardate uses :rand.uniform" do
    type :essential
    calling_fn module: CaptainsLog, name: :random_stardate
    called_fn module: :rand, name: :uniform
    comment Constants.captains_log_use_rand_uniform()
    suppress_if Constants.solution_deprecated_random_module(), :fail
    suppress_if "random_stardate does not use :rand.uniform_real", :fail
    suppress_if "random_stardate does not use Enum.random", :fail
end


  check_source "format_stardate uses erlang" do
    type :essential
    comment Constants.captains_log_use_erlang()

    check(%Source{code_ast: code_ast}) do
      {_, erlang?} =
        Macro.prewalk(code_ast, false, fn node, acc ->
          case node do
            # usage :io_lib.format/2
            {{:., _, [:io_lib, :format]}, _, _} ->
              {node, true}

            # usage :erlang.function_name/arity
            # matches any function call from :erlang module
            {{:., _, [:erlang, _]}, _, _} ->
              {node, true}

            _ ->
              {node, acc}
          end
        end)

      erlang?
    end
  end
end
