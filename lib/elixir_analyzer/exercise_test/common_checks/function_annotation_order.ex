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
    {_, attrs} = Macro.prewalk(ast, [], &traverse/2)

    attrs
    |> Enum.reverse()
    |> chunk_definitions()
    |> merge_definitions()
    |> check_errors()
  end

  defp traverse({:defmodule, _, [{:__aliases__, _, aliases}, [do: do_block]]}, acc) do
    context = {:context, Module.concat(aliases)}
    {do_block, [context | acc]}
  end

  defp traverse({:@, _meta, [{:spec, _, [{:"::", _, [{fn_name, _, _} | _]}]} | _]} = ast, acc) do
    {ast, [{:spec, fn_name} | acc]}
  end

  defp traverse({:@, _, [{:spec, _, [{fn_name, _, _}]}]} = ast, acc) do
    {ast, [{:spec, fn_name} | acc]}
  end

  defp traverse({:@, _, [{:doc, _, _}]} = ast, acc) do
    {ast, [:doc | acc]}
  end

  defp traverse({op, _, [{:when, _, [{fn_name, _, _} | _]} | _]} = ast, acc)
       when op in @def_ops do
    {ast, [{op, fn_name} | acc]}
  end

  defp traverse({op, _, [{fn_name, _, _} | _]} = ast, acc)
       when op in @def_ops do
    {ast, [{op, fn_name} | acc]}
  end

  defp traverse(ast, acc) do
    {ast, acc}
  end

  defp check_errors(attrs) do
    Enum.reduce(attrs, [], fn attr, acc ->
      check_wrong_order(acc, attr)
    end)
    |> Enum.reverse()
  end

  defp check_wrong_order(acc, attr) do
    case attr.operations do
      [:spec, :doc | _] ->
        [order_error_msg(attr) | acc]

      [hd | tl] when hd in @def_ops ->
        if :spec in tl or :doc in tl do
          [order_error_msg(attr) | acc]
        else
          acc
        end

      _ ->
        acc
    end
  end

  defp chunk_definitions(definitions) do
    chunk_fun = fn
      {:context, context}, %{context: nil} = chunk ->
        {:cont, %{chunk | context: context}}

      {:context, context}, %{context: _} = chunk ->
        {:cont, chunk, %{context: context, name: nil, operations: []}}

      {op, name}, %{name: name, operations: ops} = chunk ->
        {:cont, %{chunk | operations: [op | ops]}}

      {op, name}, %{name: nil, operations: ops} = chunk ->
        {:cont, %{chunk | name: name, operations: [op | ops]}}

      {op, name}, %{operations: ops} = chunk ->
        {:cont, %{chunk | operations: Enum.reverse(ops)},
         %{context: chunk.context, name: name, operations: [op]}}

      :doc, %{name: nil, operations: ops} = chunk ->
        {:cont, %{chunk | operations: [:doc | ops]}}

      :doc, %{operations: [:spec] = ops} = chunk ->
        {:cont, %{chunk | operations: [:doc | ops]}}

      :doc, %{operations: ops} = chunk ->
        {:cont, %{chunk | operations: Enum.reverse(ops)},
         %{context: chunk.context, name: nil, operations: [:doc]}}
    end

    Enum.chunk_while(
      definitions,
      %{name: nil, operations: [], context: nil},
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
    if (first.name == second.name || second.name == nil) and first.context == second.context do
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

  defp order_error_msg(attr) do
    fn_name = attr.name

    fn_op = Enum.find(attr.operations, &Enum.member?(@def_ops, &1))

    actual = """
    @spec #{fn_name}
    @doc
    #{fn_op} #{fn_name}
    """

    expected = """
    @doc
    @spec #{fn_name}
    #{fn_op} #{fn_name}
    """

    {:fail,
     %Comment{
       type: :informative,
       name: Constants.solution_function_annotation_order(),
       comment: Constants.solution_function_annotation_order(),
       params: %{
         actual: actual,
         expected: expected
       }
     }}
  end
end
