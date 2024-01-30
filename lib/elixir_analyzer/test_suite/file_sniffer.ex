defmodule ElixirAnalyzer.TestSuite.FileSniffer do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise File Sniffer
  """

  alias ElixirAnalyzer.Constants
  use ElixirAnalyzer.ExerciseTest

  assert_call "use <<>> to pattern match a bitstring in function body" do
    type :essential
    comment Constants.file_sniffer_use_bitstring()
    called_fn name: :<<>>
    calling_fn module: FileSniffer, name: :type_from_binary
  end

  assert_call "use :: in bitstrings to specify segment type when pattern matching in function body" do
    type :essential
    comment Constants.file_sniffer_use_bitstring()
    called_fn name: :"::"
    calling_fn module: FileSniffer, name: :type_from_binary
  end
end
