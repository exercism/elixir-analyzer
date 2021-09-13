defmodule ElixirAnalyzer.ExerciseTest.CommonChecks do
  @moduledoc """
  This module aggregates all common checks that should be run on every single solution.
  """

  alias ElixirAnalyzer.ExerciseTest.CommonChecks.FunctionNames
  alias ElixirAnalyzer.ExerciseTest.CommonChecks.VariableNames
  alias ElixirAnalyzer.ExerciseTest.CommonChecks.ModuleAttributeNames
  alias ElixirAnalyzer.ExerciseTest.CommonChecks.ModulePascalCase
  alias ElixirAnalyzer.ExerciseTest.CommonChecks.Indentation
  alias ElixirAnalyzer.Comment

  # CommonChecks that use feature or assert_call should be called here
  defmacro __using__(_opts) do
    quote do
      use ElixirAnalyzer.ExerciseTest.CommonChecks.DebugFunctions
    end
  end

  @spec run(Macro.t(), String.t()) :: [{:pass | :fail | :skip, %Comment{}}]
  def run(code_ast, code_as_string) when is_binary(code_as_string) do
    [
      FunctionNames.run(code_ast),
      VariableNames.run(code_ast),
      ModuleAttributeNames.run(code_ast),
      ModulePascalCase.run(code_ast),
      Indentation.run(code_ast, code_as_string)
    ]
    |> List.flatten()
  end
end
