defmodule ElixirAnalyzer.TestSuite.ListOps do
  @moduledoc """
  This is an exercise analyzer test suite for the practive exercise list-ops 
  """

  use ElixirAnalyzer.ExerciseTest
  alias ElixirAnalyzer.Constants

  assert_no_call "do not call List module" do
    type :essential
    called_fn module: List, name: :_
    comment Constants.list_ops_do_not_use_list_functions()
  end

  assert_no_call "do not call Enum module" do
    type :essential
    called_fn module: Enum, name: :_
    comment Constants.list_ops_do_not_use_list_functions()
  end

  assert_no_call "do not call Stream module" do
    type :essential
    called_fn module: Stream, name: :_
    comment Constants.list_ops_do_not_use_list_functions()
  end

  assert_no_call "do not use ++" do
    type :essential
    called_fn name: :++
    comment Constants.list_ops_do_not_use_list_functions()
  end

  assert_no_call "do not use --" do
    type :essential
    called_fn name: :--
    comment Constants.list_ops_do_not_use_list_functions()
  end

  assert_no_call "do not use hd" do
    type :essential
    called_fn name: :hd
    comment Constants.list_ops_do_not_use_list_functions()
  end

  assert_no_call "do not use tl" do
    type :essential
    called_fn name: :tl
    comment Constants.list_ops_do_not_use_list_functions()
  end

  assert_no_call "do not use in" do
    type :essential
    called_fn name: :in
    comment Constants.list_ops_do_not_use_list_functions()
  end

  assert_no_call "do not use for" do
    type :essential
    called_fn name: :for
    comment Constants.list_ops_do_not_use_list_functions()
  end

  assert_no_call "do not use Kernel.length" do
    type :essential
    called_fn module: Kernel, name: :length
    comment Constants.list_ops_do_not_use_list_functions()
  end
end
