defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.DocSpecOrder do
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
    |> chuck_definitions()
    |> Enum.map(&to_map/1)
    |> check_errors
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
  end

  defp check_wrong_order(acc, attr) do
    case attr.order do
      [:spec, :doc] -> [order_error_msg(attr) | acc]
      _ -> acc
    end
  end

  defp check_name_match(acc, %{definition: {_, name}, spec: spec} = attr) do
    if name == spec do
      acc
    else
      [spec_name_error_msg(attr) | acc]
    end
  end

  defp check_name_match(acc, _), do: acc

  defp chuck_definitions(definitions) do
    chunk_fun = fn
      el, acc ->
        case el do
          {op, _} when op in @def_ops -> {:cont, Enum.reverse([el | acc]), []}
          _ -> {:cont, [el | acc]}
        end
    end

    Enum.chunk_while(definitions, [], chunk_fun, &{:cont, &1})
  end

  defp to_map(attr) do
    Enum.reduce(attr, %{order: []}, fn
      {:spec = op, name}, acc ->
        acc |> Map.put(op, name) |> Map.update!(:order, &Enum.reverse([op | &1]))

      :doc = op, acc ->
        Map.update!(acc, :order, &Enum.reverse([op | &1]))

      {op, name}, acc when op in @def_ops ->
        Map.put(acc, :definition, {op, name})
    end)
  end

  defp order_error_msg(attr) do
    {fn_op, fn_name} = attr.definition

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
       name: Constants.solution_doc_spec_order(),
       comment: Constants.solution_doc_spec_order(),
       params: %{
         actual: actual,
         expected: expected
       }
     }}
  end
end
