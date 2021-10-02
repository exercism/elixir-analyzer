defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.ExemplarComparison do
  @moduledoc """
  Compares the solution to the exemplar solution for concept exercises.
  Ignores practice exercises.
  """

  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Comment

  @spec run(Macro.t(), nil | Macro.t()) :: [{:pass | :fail | :skip, %Comment{}}]
  def run(_ast, nil), do: []

  def run(code_ast, exemplar_ast) do
    if Macro.to_string(code_ast) == Macro.to_string(exemplar_ast) do
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
end
