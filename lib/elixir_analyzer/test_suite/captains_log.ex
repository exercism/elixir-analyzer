defmodule ElixirAnalyzer.TestSuite.CaptainsLog do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Captains Log
  """
  use ElixirAnalyzer.ExerciseTest
  alias ElixirAnalyzer.Constants

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

  assert_call "format_stardate uses :io_lib" do
    type :essential
    calling_fn module: CaptainsLog, name: :format_stardate
    called_fn module: :io_lib, name: :_
    comment Constants.captains_log_use_io_lib()
  end
end
