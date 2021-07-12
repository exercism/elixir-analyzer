defmodule ElixirAnalyzer.ExerciseTest.CommonChecks do
  @moduledoc """
  This module aggregates all common checks that should be run on every single solution.
  """

  alias ElixirAnalyzer.ExerciseTest.CommonChecks.FunctionNames
  alias ElixirAnalyzer.ExerciseTest.CommonChecks.VariableNames
  alias ElixirAnalyzer.ExerciseTest.CommonChecks.ModuleAttributeNames
  alias ElixirAnalyzer.ExerciseTest.CommonChecks.ModulePascalCase
  alias ElixirAnalyzer.Comment

  @spec run(Macro.t(), String.t()) :: [{:pass | :fail | :skip, %Comment{}}]
  def run(code_ast, code_as_string) when is_binary(code_as_string) do
    [
      FunctionNames.run(code_ast),
      VariableNames.run(code_ast),
      ModuleAttributeNames.run(code_ast),
      ModulePascalCase.run(code_ast)
    ]
    |> List.flatten()
  end
end
