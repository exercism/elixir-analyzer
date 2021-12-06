defmodule ElixirAnalyzer.TestSuite.DNAEncoding do
  @moduledoc """
  This is an exercise analyzer extension module for the DNA Encoding concept exercise
  """

  use ElixirAnalyzer.ExerciseTest
  alias ElixirAnalyzer.Constants

  assert_no_call "does not call Enum.reduce" do
    type :essential
    called_fn module: Enum, name: :reduce
    comment Constants.dna_encoding_use_recursion()
  end

  assert_no_call "does not call List.foldr" do
    type :essential
    called_fn module: List, name: :foldr
    comment Constants.dna_encoding_use_recursion()
  end

  assert_no_call "does not call the for/1 function" do
    type :essential
    called_fn name: :for
    comment Constants.dna_encoding_use_recursion()
  end
end
