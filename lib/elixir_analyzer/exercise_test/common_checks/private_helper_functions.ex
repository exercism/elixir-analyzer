defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.PrivateHelperFunctions do
  @moduledoc """
  Compare the module functions to the exemploid and check if helper functions should be private.
  """

  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Comment

  @def_ops [:def, :defp, :defmacro, :defmacrop, :defguard, :defguardp]
  @public_ops [:def, :defmacro, :defguard]

  @spec run(Macro.t(), nil | Macro.t()) :: [{:pass | :fail | :skip, %Comment{}}]
  def run(_ast, nil), do: []

  def run(code_ast, exemplar_ast) do
    {_, code_definitions} = Macro.prewalk(code_ast, MapSet.new(), &traverse/2)
    {_, exemploid_definitions} = Macro.prewalk(exemplar_ast, MapSet.new(), &traverse/2)

    case find_public_helpers(code_definitions, exemploid_definitions) do
      [] ->
        []

      [{wrong_definition, correct_definition} | _] ->
        [
          {:fail,
           %Comment{
             type: :informative,
             name: Constants.solution_private_helper_functions(),
             comment: Constants.solution_private_helper_functions(),
             params: %{
               expected: correct_definition,
               actual: wrong_definition
             }
           }}
        ]
    end
  end

  defp traverse({op, _meta, [{:when, _, [{name, _, _} | _]} | _]} = ast, names)
       when op in @def_ops do
    {ast, MapSet.put(names, {op, name})}
  end

  defp traverse({op, _meta, [{name, _meta2, _arguments} | _]} = ast, names) when op in @def_ops do
    {ast, MapSet.put(names, {op, name})}
  end

  defp traverse(ast, names) do
    {ast, names}
  end

  defp find_public_helpers(code_definitions, exemploid_definitions) do
    MapSet.difference(code_definitions, exemploid_definitions)
    |> Enum.filter(fn {op, _} -> op in @public_ops end)
    |> Enum.map(fn {op, name} -> {"#{op} #{name}", "#{op}p #{name}"} end)
  end
end
