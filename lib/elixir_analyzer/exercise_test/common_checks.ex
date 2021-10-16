defmodule ElixirAnalyzer.ExerciseTest.CommonChecks do
  @moduledoc """
  This module aggregates all common checks that should be run on every single solution.
  """

  alias ElixirAnalyzer.ExerciseTest.CommonChecks.{
    FunctionNames,
    VariableNames,
    ModuleAttributeNames,
    ModulePascalCase,
    CompilerWarnings,
    ExemplarComparison,
    Indentation,
    FunctionAnnotationOrder
  }

  alias ElixirAnalyzer.Comment

  # CommonChecks that use feature or assert_call should be called here
  defmacro __using__(_opts) do
    quote do
      use ElixirAnalyzer.ExerciseTest.CommonChecks.DebugFunctions
      use ElixirAnalyzer.ExerciseTest.CommonChecks.LastLineAssignment
      use ElixirAnalyzer.ExerciseTest.CommonChecks.ListPrependHead
      use ElixirAnalyzer.ExerciseTest.CommonChecks.UncommonErrors
    end
  end

  @spec run(Macro.t(), String.t(), nil | Macro.t()) :: [{:pass | :fail | :skip, %Comment{}}]
  def run(code_ast, code_as_string, exemplar_ast) when is_binary(code_as_string) do
    [
      FunctionNames.run(code_ast),
      VariableNames.run(code_ast),
      ModuleAttributeNames.run(code_ast),
      ModulePascalCase.run(code_ast),
      CompilerWarnings.run(code_ast),
      ExemplarComparison.run(code_ast, exemplar_ast),
      Indentation.run(code_ast, code_as_string),
      FunctionAnnotationOrder.run(code_ast)
    ]
    |> List.flatten()
  end
end
