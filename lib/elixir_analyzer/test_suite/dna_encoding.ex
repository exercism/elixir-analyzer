defmodule ElixirAnalyzer.TestSuite.DNAEncoding do
  @moduledoc """
  This is an exercise analyzer extension module for the DNA Encoding concept exercise
  """

  use ElixirAnalyzer.ExerciseTest
  alias ElixirAnalyzer.Constants

  assert_no_call "does not call any Enum functions" do
    type :essential
    called_fn module: Enum, name: :_
    comment Constants.dna_encoding_use_recursion()
  end

  assert_no_call "does not call any Stream functions" do
    type :essential
    called_fn module: Stream, name: :_
    comment Constants.dna_encoding_use_recursion()
  end

  assert_no_call "does not call any List functions" do
    type :essential
    called_fn module: List, name: :_
    comment Constants.dna_encoding_use_recursion()
  end

  assert_no_call "does not use list comprehensions" do
    type :essential
    called_fn name: :for
    comment Constants.dna_encoding_use_recursion()
  end
end
