defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.BooleanFunctions do
  @moduledoc """
  Reports the first boolean function with a name that's not appropriate.

  Doesn't report more if there are more.
  A single comment should be enough for the student to know what to fix.

  Common check to be run on every single solution.
  """

  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Comment

  @spec run(Macro.t()) :: [{:pass | :fail, Comment.t()}]
  def run(ast) do
    {_, function_names} =
      Macro.prewalk(ast, %{defs: [], defguards: [], defmacros: []}, &traverse/2)

    function_names
    |> Enum.map(fn {type, list} -> {type, List.last(list)} end)
    |> Enum.map(&to_comment/1)
    |> List.flatten()
  end

  @def_ops [:def, :defp, :defmacro, :defmacrop, :defguard, :defguardp]
  defp traverse({op, _meta, [{name, _meta2, _parameters} | _]} = ast, acc) when op in @def_ops do
    name = to_string(name)

    if correct_name?(op, name) do
      {ast, acc}
    else
      {ast, put_correct_name(acc, op, name)}
    end
  end

  defp traverse(ast, acc) do
    {ast, acc}
  end

  defp correct_name?(type, name) do
    starts_with_is = String.starts_with?(name, "is_")
    end_with_? = String.ends_with?(name, "?")

    cond do
      starts_with_is and end_with_? -> false
      starts_with_is and type in [:def, :defp] -> false
      end_with_? and type in [:defguard, :defguardp] -> false
      true -> true
    end
  end

  defp put_correct_name(acc, type, wrong_name) when type in [:def, :defp] do
    name =
      wrong_name
      |> String.replace_leading("is_", "")
      |> String.replace_trailing("?", "")

    Map.update!(acc, :defs, &[{"#{type} #{wrong_name}", "#{type} #{name}?"} | &1])
  end

  defp put_correct_name(acc, type, wrong_name) when type in [:defguard, :defguardp] do
    name =
      wrong_name
      |> String.replace_leading("is_", "")
      |> String.replace_trailing("?", "")

    Map.update!(acc, :defguards, &[{"#{type} #{wrong_name}", "#{type} is_#{name}"} | &1])
  end

  defp put_correct_name(acc, type, wrong_name) do
    option1 = String.replace_leading(wrong_name, "is_", "")
    option2 = String.replace_trailing(wrong_name, "?", "")

    Map.update!(
      acc,
      :defmacros,
      &[{"#{type} #{wrong_name}", "#{type} #{option1}", "#{type} #{option2}"} | &1]
    )
  end

  defp to_comment({_, nil}), do: []

  defp to_comment({:defs, {wrong_def, correct_def}}) do
    {:fail,
     %Comment{
       type: :actionable,
       name: Constants.solution_def_with_is(),
       comment: Constants.solution_def_with_is(),
       params: %{
         expected: correct_def,
         actual: wrong_def
       }
     }}
  end

  defp to_comment({:defguards, {wrong_def, correct_def}}) do
    {:fail,
     %Comment{
       type: :actionable,
       name: Constants.solution_defguard_with_question_mark(),
       comment: Constants.solution_defguard_with_question_mark(),
       params: %{
         expected: correct_def,
         actual: wrong_def
       }
     }}
  end

  defp to_comment({:defmacros, {wrong_def, correct_?, correct_is}}) do
    {:fail,
     %Comment{
       type: :actionable,
       name: Constants.solution_defmacro_with_is_and_question_mark(),
       comment: Constants.solution_defmacro_with_is_and_question_mark(),
       params: %{
         actual: wrong_def,
         option1: correct_?,
         option2: correct_is
       }
     }}
  end
end
