defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.BooleanFunctions do
  @moduledoc """
  Reports the first boolean function with a name that's not appropriate.

  Doesn't report more if there are more.
  A single comment should be enough for the student to know what to fix.

  Common check to be run on every single solution.
  """

  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Comment

  @spec run(Macro.t()) :: [{:pass | :fail | :skip, %Comment{}}]
  def run(ast) do
    {_, %{function_names: function_names}} =
      Macro.prewalk(ast, %{function_names: []}, &traverse/2)

    case List.last(function_names) do
      nil ->
        []

      {def_type, name} ->
        {wrong_def, correct_def} = render_names(def_type, name)

        [
          {:fail,
           %Comment{
             type: :actionable,
             name: Constants.solution_boolean_functions(),
             comment: Constants.solution_boolean_functions(),
             params: %{
               expected: correct_def,
               actual: wrong_def
             }
           }}
        ]
    end
  end

  @def_ops [:def, :defp, :defmacro, :defmacrop, :defguard, :defguardp]
  defp traverse({op, _meta, [{name, _meta2, _parameters} | _]} = ast, acc) when op in @def_ops do
    name = to_string(name)

    if correct_name?(op, name) do
      {ast, acc}
    else
      {ast, Map.update!(acc, :function_names, &[{op, name} | &1])}
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

  defp render_names(type, name) do
    starts_with_is = String.starts_with?(name, "is_")
    end_with_? = String.ends_with?(name, "?")

    name_without_is = String.replace_leading(name, "is_", "")
    name_without_? = String.replace_trailing(name, "?", "")

    correct_name =
      cond do
        type in [:def, :defp] and starts_with_is and end_with_? -> name_without_is
        type in [:def, :defp] -> name_without_is <> "?"
        type in [:defguard, :defguardp] and starts_with_is and end_with_? -> name_without_?
        type in [:defguard, :defguardp] -> "is_" <> name_without_?
        true -> "#{name_without_?} or #{type} #{name_without_is}"
      end

    {"#{type} #{name}", "#{type} #{correct_name}"}
  end
end
