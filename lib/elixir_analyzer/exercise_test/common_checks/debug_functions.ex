defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.DebugFunctions do
  @moduledoc """
  This is an exercise analyzer extension module used for common tests lookin for debugging functions
  """

  alias ElixirAnalyzer.Comment
  alias ElixirAnalyzer.Submission

  # Suppressing common tests prevents this module to recursively call common tests
  use ElixirAnalyzer.ExerciseTest, suppress_common_tests: true

  assert_no_call "solution doesn't use IO.inspect" do
    type :informational
    comment ElixirAnalyzer.Constants.solution_debug_functions()
    called_fn module: IO, name: :inspect
  end

  @spec run(String.t()) :: [{:fail, %Comment{}}]
  def run(code_as_string) do
    %Submission{comments: comments} =
      %Submission{code_file: "", code_path: "", path: "", analysis_module: __MODULE__}
      |> __MODULE__.analyze(code_as_string)

    case comments do
      [%{comment: comment, type: type} | _] ->
        [{:fail, %Comment{comment: comment, type: type, name: comment}}]

      _ ->
        []
    end
  end
end
