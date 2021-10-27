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
    BooleanFunctions,
    ExemplarComparison,
    Indentation,
    PrivateHelperFunctions,
    Comments
  }

  alias ElixirAnalyzer.Comment
  alias ElixirAnalyzer.Source

  # CommonChecks that use feature or assert_call should be called here
  defmacro __using__(_opts) do
    quote do
      use ElixirAnalyzer.ExerciseTest.CommonChecks.DebugFunctions
      use ElixirAnalyzer.ExerciseTest.CommonChecks.LastLineAssignment
      use ElixirAnalyzer.ExerciseTest.CommonChecks.ListPrependHead
      use ElixirAnalyzer.ExerciseTest.CommonChecks.UncommonErrors
    end
  end

  @spec run(Source.t()) :: [{:pass | :fail | :skip, %Comment{}}]
  def run(%Source{
        code_path: code_path,
        code_ast: code_ast,
        code_string: code_string,
        exercise_type: type,
        exemploid_ast: exemploid_ast
      }) do
    [
      FunctionNames.run(code_ast),
      VariableNames.run(code_ast),
      ModuleAttributeNames.run(code_ast),
      ModulePascalCase.run(code_ast),
      CompilerWarnings.run(code_path, code_ast),
      BooleanFunctions.run(code_ast),
      ExemplarComparison.run(code_ast, type, exemploid_ast),
      Indentation.run(code_ast, code_string),
      PrivateHelperFunctions.run(code_ast, exemploid_ast),
      Comments.run(code_ast, code_string)
    ]
    |> List.flatten()
  end
end
