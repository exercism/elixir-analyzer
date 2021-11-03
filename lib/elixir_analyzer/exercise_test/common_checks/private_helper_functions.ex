defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.PrivateHelperFunctions do
  @moduledoc """
  Compare the module functions to the exemploid and check if helper functions should be private.
  """

  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Comment

  @public_ops [:def, :defmacro, :defguard]

  @spec run(Macro.t(), nil | Macro.t()) :: [{:pass | :fail | :skip, %Comment{}}]
  def run(_ast, nil), do: []

  def run(code_ast, exemploid_ast) do
    {_, code_definitions} = Macro.prewalk(code_ast, [], &traverse/2)
    {_, exemploid_definitions} = Macro.prewalk(exemploid_ast, [], &traverse/2)

    case Enum.reverse(find_public_helpers(code_definitions, exemploid_definitions)) do
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

  defp traverse({op, _meta, [{:when, _, [{name, _, args} | _]} | _]} = ast, names)
       when op in @public_ops do
    definition = {op, name, if(is_atom(args), do: 0, else: length(args))}
    {ast, [definition | names]}
  end

  defp traverse({op, _meta, [{name, _, args} | _]} = ast, names) when op in @public_ops do
    definition = {op, name, if(is_atom(args), do: 0, else: length(args))}
    {ast, [definition | names]}
  end

  defp traverse(ast, names) do
    {ast, names}
  end

  defp find_public_helpers(code_definitions, exemploid_definitions) do
    (Enum.uniq(code_definitions) -- exemploid_definitions)
    |> Enum.map(&print_definition/1)
  end

  defp print_definition({op, name, arity}) do
    args = make_args(arity)
    {"#{op} #{name}(#{args})", "#{op}p #{name}(#{args})"}
  end

  defp make_args(arity) do
    for(_ <- 1..arity//1, do: "_")
    |> Enum.join(", ")
  end
end
