defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.ExemplarComparison do
  @moduledoc """
  Compares the solution to the exemplar solution for concept exercises.
  Ignores practice exercises.
  """

  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Comment

  @spec run(Macro.t(), atom, Macro.t()) :: [{:pass | :fail | :skip, %Comment{}}]

  def run(code_ast, :concept, exemplar_ast) do
    if format(code_ast) == format(exemplar_ast) do
      [
        {:pass,
         %Comment{
           type: :celebratory,
           name: Constants.solution_same_as_exemplar(),
           comment: Constants.solution_same_as_exemplar()
         }}
      ]
    else
      []
    end
  end

  def run(_, _, _), do: []

  defp format(ast) do
    ast
    |> Macro.to_string()
    |> Code.format_string!(line_length: 120, force_do_end_blocks: true)
    |> IO.iodata_to_binary()
  end
end
