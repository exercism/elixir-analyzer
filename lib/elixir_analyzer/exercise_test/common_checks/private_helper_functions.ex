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
    {_, code_hidden} = Macro.prewalk(code_ast, [], &find_hidden/2)
    {_, code_def} = Macro.prewalk(code_ast, [], &traverse/2)
    {_, exemploid_def} = Macro.prewalk(exemploid_ast, [], &traverse/2)

    case find_public_helpers(code_def, code_hidden, exemploid_def) |> Enum.reverse() do
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

  defp find_hidden({_, _, args} = ast, names) when is_list(args) do
    {ast, do_find_hidden(args, names)}
  end

  defp find_hidden(ast, names), do: {ast, names}

  defp do_find_hidden([doc, function | rest], names) do
    hidden? =
      match?({:@, _, [{:doc, _, [false]}]}, doc) or match?({:@, _, [{:impl, _, [true]}]}, doc)

    def? = function_def?(function)

    if hidden? and def? do
      names = [get_function_data(function) | names]
      do_find_hidden(rest, names)
    else
      do_find_hidden([function | rest], names)
    end
  end

  defp do_find_hidden(_, names), do: names

  defp function_def?({_op, _, [{:when, _, [{_name, _, _args} | _]} | _]}), do: true
  defp function_def?({_op, _, [{_name, _, _args} | _]}), do: true
  defp function_def?(_node), do: false

  defp get_function_data({op, _, [{:when, _, [{name, _, args} | _]} | _]}) do
    {op, name, if(is_atom(args), do: 0, else: length(args))}
  end

  defp get_function_data({op, _, [{name, _, args} | _]}) do
    {op, name, if(is_atom(args), do: 0, else: length(args))}
  end

  defp traverse({op, _, [{:when, _, [{name, _, args} | _]} | _]} = ast, names)
       when op in @public_ops do
    definition = {op, name, if(is_atom(args), do: 0, else: length(args))}
    {ast, [definition | names]}
  end

  defp traverse({op, _, [{name, _, args} | _]} = ast, names) when op in @public_ops do
    definition = {op, name, if(is_atom(args), do: 0, else: length(args))}
    {ast, [definition | names]}
  end

  defp traverse(ast, names), do: {ast, names}

  defp find_public_helpers(code_def, code_hidden, exemploid_def) do
    ((Enum.uniq(code_def) -- exemploid_def) -- code_hidden)
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
