defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.Comments do
  @moduledoc """
  Reports if concept exercise boilerplate comments or any TODO/FIXME comments are found.
  """

  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Comment

  @spec run(Macro.t(), String.t()) :: [{:pass | :fail, Comment.t()}]
  def run(ast, string) do
    boilerplate_comment_check =
      if has_comment_matching_pattern?(
           ast,
           string,
           concept_exercise_boilerplate_comment_pattern()
         ) do
        {:fail,
         %Comment{
           type: :actionable,
           name: Constants.solution_boilerplate_comment(),
           comment: Constants.solution_boilerplate_comment()
         }}
      end

    todo_comment_check =
      if has_comment_matching_pattern?(
           ast,
           string,
           generic_todo_comment_pattern()
         ) do
        {:fail,
         %Comment{
           type: :informative,
           name: Constants.solution_todo_comment(),
           comment: Constants.solution_todo_comment()
         }}
      end

    Enum.filter([boilerplate_comment_check, todo_comment_check], & &1)
  end

  defp concept_exercise_boilerplate_comment_pattern() do
    # for example:
    # > # Please define the 'expected_minutes_in_oven/0' function
    # > # Please implement the ask_class/0 function
    # > # Please implement the struct with the specified fields
    # > # Please implement DivisionByZeroError here.

    # they're always used on their own line, hence the m (multiline) flag and beginning-of-line ^ anchor
    ~r/^\s*# Please (implement|define) /mi
  end

  defp generic_todo_comment_pattern() do
    ~r/#(\s)*(TODO|FIXME):?/i
  end

  defp has_comment_matching_pattern?(ast, string, pattern) do
    Regex.match?(pattern, string) and not Regex.match?(pattern, Macro.to_string(ast))
  end
end
