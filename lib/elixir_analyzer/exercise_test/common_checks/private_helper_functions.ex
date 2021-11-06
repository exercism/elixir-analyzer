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
    acc = %{module: [], definitions: []}

    {_, %{definitions: code_definitions}} =
      Macro.traverse(code_ast, acc, &annotate/2, &find_definition/2)

    {_, %{definitions: exemploid_definitions}} =
      Macro.traverse(exemploid_ast, acc, &annotate/2, &find_definition/2)

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

  defp annotate(node, %{module: modules} = acc) do
    case module_name(node) do
      {:ok, module} -> {node, %{acc | module: [module | modules]}}
      :not_defmodule -> {node, acc}
    end
  end

  defp find_definition(node, %{module: modules, definitions: definitions} = acc) do
    acc =
      case module_name(node) do
        {:ok, _} -> %{acc | module: tl(modules)}
        :not_defmodule -> acc
      end

    case public_definition(node, modules) do
      {:ok, definition} -> {node, %{acc | definitions: [definition | definitions]}}
      :not_public_definition -> {node, acc}
    end
  end

  def module_name({:defmodule, _, [{:__aliases__, _, module}, _]}), do: {:ok, module}
  def module_name(_node), do: :not_defmodule

  defp public_definition({op, _meta, [{:when, _, [{name, _, args} | _]} | _]}, module)
       when op in @public_ops do
    {:ok, {module, op, name, if(is_atom(args), do: 0, else: length(args))}}
  end

  defp public_definition({op, _meta, [{name, _, args} | _]}, module) when op in @public_ops do
    {:ok, {module, op, name, if(is_atom(args), do: 0, else: length(args))}}
  end

  defp public_definition(_node, _module), do: :not_public_definition

  defp find_public_helpers(code_definitions, exemploid_definitions) do
    exemploid_modules =
      exemploid_definitions |> Enum.map(fn {module, _, _, _} -> module end) |> Enum.uniq()

    (Enum.uniq(code_definitions) -- exemploid_definitions)
    |> Enum.filter(fn {module, _, _, _} -> module in exemploid_modules end)
    |> Enum.map(&print_definition/1)
  end

  defp print_definition({_module, op, name, arity}) do
    args = make_args(arity)
    {"#{op} #{name}(#{args})", "#{op}p #{name}(#{args})"}
  end

  defp make_args(arity) do
    for(_ <- 1..arity//1, do: "_")
    |> Enum.join(", ")
  end
end
