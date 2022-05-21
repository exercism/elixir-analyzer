defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.PrivateHelperFunctions do
  @moduledoc """
  Compare the module functions to the exemploid and check if helper functions should be private.
  """

  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Comment

  @public_ops [:def, :defmacro, :defguard]

  @spec run(Macro.t(), nil | Macro.t()) :: [{:pass | :fail, Comment.t()}]
  def run(_ast, nil), do: []

  def run(code_ast, exemploid_ast) do
    acc = %{module: [], definitions: []}

    {_, %{definitions: code_definitions}} =
      Macro.traverse(code_ast, acc, &annotate/2, &find_definition/2)

    # Some functions have to be public even though they don't appear in the exemploid.
    # That's because they can be indirectly used with dynamic dispatch by the standard library.
    {_, %{exceptions: exceptions}} =
      Macro.traverse(code_ast, %{module: [], exceptions: []}, &annotate/2, &find_exceptions/2)

    {_, %{definitions: exemploid_definitions}} =
      Macro.traverse(exemploid_ast, acc, &annotate/2, &find_definition/2)

    case Enum.reverse(find_public_helpers(code_definitions, exemploid_definitions, exceptions)) do
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
      {:ok, new_definitions} -> {node, %{acc | definitions: new_definitions ++ definitions}}
      :not_public_definition -> {node, acc}
    end
  end

  defp module_name({:defmodule, _, [{:__aliases__, _, module}, _]}), do: {:ok, module}
  defp module_name(_node), do: :not_defmodule

  defp public_definition({op, _meta, [{:when, _, [{name, _, args} | _]} | _]}, module)
       when op in @public_ops do
    definitions =
      args
      |> get_arities
      |> Enum.map(fn arity -> {module, op, name, arity} end)

    {:ok, definitions}
  end

  defp public_definition({op, _meta, [{name, _, args} | _]}, module) when op in @public_ops do
    definitions =
      args
      |> get_arities
      |> Enum.map(fn arity -> {module, op, name, arity} end)

    {:ok, definitions}
  end

  defp public_definition(_node, _module), do: :not_public_definition

  defp get_arities(args) when is_atom(args), do: [0]

  defp get_arities(args) when is_list(args) do
    length_args = length(args)
    default_values = Enum.count(args, &match?({:\\, _, _}, &1))

    length_args..(length_args - default_values)//-1
  end

  defp find_public_helpers(code_definitions, exemploid_definitions, exceptions) do
    exemploid_modules =
      exemploid_definitions |> Enum.map(fn {module, _, _, _} -> module end) |> Enum.uniq()

    (Enum.uniq(code_definitions) -- exemploid_definitions)
    |> Enum.filter(fn {module, _, _, _} -> module in exemploid_modules end)
    |> Enum.reject(fn definition -> definition in exceptions end)
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

  @exceptional_enum_sort_functions %{
    sort: %{arity: 2, sorter_argument_position: 2},
    sort_by: %{arity: 3, sorter_argument_position: 3}
  }

  defp find_exceptions(
         {:|>, _,
          [
            _,
            {{:., [], [{:__aliases__, _, [:Enum]}, function_name]}, [], arguments}
          ]} = node,
         %{module: module, exceptions: exceptions}
       ) do
    exceptions =
      if is_map(@exceptional_enum_sort_functions[function_name]) and
           @exceptional_enum_sort_functions[function_name].arity == length(arguments) + 1 do
        sorter_arg =
          Enum.at(
            arguments,
            @exceptional_enum_sort_functions[function_name].sorter_argument_position - 2
          )

        find_enum_sort_exceptions(sorter_arg, %{module: module, exceptions: exceptions})
      else
        exceptions
      end

    {node, %{module: module, exceptions: exceptions}}
  end

  defp find_exceptions(
         {{:., [], [{:__aliases__, _, [:Enum]}, function_name]}, [], arguments} = node,
         %{module: module, exceptions: exceptions}
       ) do
    exceptions =
      if is_map(@exceptional_enum_sort_functions[function_name]) and
           @exceptional_enum_sort_functions[function_name].arity == length(arguments) do
        sorter_arg =
          Enum.at(
            arguments,
            @exceptional_enum_sort_functions[function_name].sorter_argument_position - 1
          )

        find_enum_sort_exceptions(sorter_arg, %{module: module, exceptions: exceptions})
      else
        exceptions
      end

    {node, %{module: module, exceptions: exceptions}}
  end

  defp find_exceptions(node, acc), do: {node, acc}

  defp find_enum_sort_exceptions(sorter_arg, %{module: module, exceptions: exceptions}) do
    case sorter_arg do
      order when order in [:asc, :desc] ->
        exceptions

      {:__aliases__, _, sorter_arg_module} when is_list(sorter_arg_module) ->
        [{[sorter_arg_module], :def, :compare, 2} | exceptions]

      {:__MODULE__, _, _} ->
        [{module, :def, :compare, 2} | exceptions]

      {order, {:__aliases__, _, sorter_arg_module}}
      when order in [:asc, :desc] and is_list(sorter_arg_module) ->
        [{[sorter_arg_module], :def, :compare, 2} | exceptions]

      {order, {:__MODULE__, _, _}} when order in [:asc, :desc] ->
        [{[module], :def, :compare, 2} | exceptions]

      _ ->
        exceptions
    end
  end
end
