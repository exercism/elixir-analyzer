defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.FunctionAnnotationOrder do
  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Comment

  @moduledoc """
  Report the first function/macro/guard where @spec module attribute comes before the
  @doc module attribute

  Common check to be run on every single solution.
  """

  @def_ops [:def, :defp, :defmacro, :defmacrop, :defguard, :defguardp]

  def run(ast) do
    acc = %{module: [], definitions: %{}}
    {_, %{definitions: definitions}} = Macro.traverse(ast, acc, &enter_node/2, &exit_node/2)

    definitions
    |> Enum.flat_map(fn {_module, ops} ->
      ops |> Enum.reverse() |> chunk_definitions() |> merge_definitions()
    end)
    |> check_errors()
  end

  defp enter_node({:defmodule, _, [{:__aliases__, _, aliases}, _]} = ast, acc) do
    module = [aliases | acc.module]
    definitions = Map.put(acc.definitions, module, [])
    {ast, %{module: module, definitions: definitions}}
  end

  defp enter_node({:@, _, [{:spec, _, [{:"::", _, [{fn_name, _, _} | _]}]} | _]} = ast, acc) do
    definitions = Map.update!(acc.definitions, acc.module, &[{:spec, fn_name} | &1])
    {ast, %{acc | definitions: definitions}}
  end

  defp enter_node({:@, _, [{:spec, _, [{fn_name, _, _}]}]} = ast, acc) do
    definitions = Map.update!(acc.definitions, acc.module, &[{:spec, fn_name} | &1])
    {ast, %{acc | definitions: definitions}}
  end

  defp enter_node({:@, _, [{:doc, _, _}]} = ast, acc) do
    definitions = Map.update!(acc.definitions, acc.module, &[:doc | &1])
    {ast, %{acc | definitions: definitions}}
  end

  defp enter_node({op, _, [{:when, _, [{fn_name, _, _} | _]} | _]} = ast, acc)
       when op in @def_ops do
    definitions = Map.update!(acc.definitions, acc.module, &[{op, fn_name} | &1])
    {ast, %{acc | definitions: definitions}}
  end

  defp enter_node({op, _, [{fn_name, _, _} | _]} = ast, acc)
       when op in @def_ops do
    definitions = Map.update!(acc.definitions, acc.module, &[{op, fn_name} | &1])
    {ast, %{acc | definitions: definitions}}
  end

  defp enter_node(ast, acc) do
    {ast, acc}
  end

  defp exit_node({:defmodule, _, _} = ast, %{module: module} = acc) do
    {ast, %{acc | module: tl(module)}}
  end

  defp exit_node(ast, acc) do
    {ast, acc}
  end

  defp chunk_definitions(definitions) do
    chunk_fun = fn
      {op, name}, %{name: name, operations: ops} = chunk ->
        {:cont, %{chunk | operations: [op | ops]}}

      {op, name}, %{name: nil, operations: ops} = chunk ->
        {:cont, %{chunk | name: name, operations: [op | ops]}}

      {op, name}, %{operations: ops} = chunk ->
        {:cont, %{chunk | operations: Enum.reverse(ops)}, %{name: name, operations: [op]}}

      :doc, %{name: nil, operations: ops} = chunk ->
        {:cont, %{chunk | operations: [:doc | ops]}}

      :doc, %{operations: [:spec] = ops} = chunk ->
        {:cont, %{chunk | operations: [:doc | ops]}}

      :doc, %{operations: ops} = chunk ->
        {:cont, %{chunk | operations: Enum.reverse(ops)}, %{name: nil, operations: [:doc]}}
    end

    Enum.chunk_while(
      definitions,
      %{name: nil, operations: []},
      chunk_fun,
      &{:cont, %{&1 | operations: Enum.reverse(&1.operations)}, nil}
    )
  end

  defp merge_definitions(definitions) do
    case definitions do
      [_] -> definitions
      definitions -> do_merge_definitions(definitions, [])
    end
  end

  defp do_merge_definitions([first | [second | rest] = tail], acc) do
    if first.name == second.name || second.name == nil do
      do_merge_definitions(rest, [
        %{name: first.name, operations: first.operations ++ second.operations} | acc
      ])
    else
      do_merge_definitions(tail, [first | acc])
    end
  end

  defp do_merge_definitions([hd | tail], acc) do
    do_merge_definitions(tail, [hd | acc])
  end

  defp do_merge_definitions([], acc) do
    Enum.reverse(acc)
  end

  defp check_errors(attrs) do
    Enum.reduce(attrs, [], &check_wrong_order/2)
  end

  defp check_wrong_order(attr, acc) do
    case attr.operations do
      [:spec, :doc | _] ->
        [order_error_msg()]

      [hd | tl] when hd in @def_ops ->
        if :spec in tl or :doc in tl do
          [order_error_msg()]
        else
          acc
        end

      _ ->
        acc
    end
  end

  defp order_error_msg() do
    {:fail,
     %Comment{
       type: :informative,
       name: Constants.solution_function_annotation_order(),
       comment: Constants.solution_function_annotation_order()
     }}
  end
end
