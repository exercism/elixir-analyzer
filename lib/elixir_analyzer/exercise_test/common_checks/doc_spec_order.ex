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
    {_, attrs} = Macro.prewalk(ast, [], &transverse/2)

    chunk_fun = fn
      el, acc ->
        case el do
          {op, _} when op in @def_ops -> {:cont, Enum.reverse([el | acc]), []}
          _ -> {:cont, [el | acc]}
        end
    end

    attrs
    |> Enum.reverse()
    |> Enum.chunk_while([], chunk_fun, &{:cont, &1})
    |> Enum.map(&to_map/1)
    |> check_errors
  end

  defp transverse({:@, _meta, [{:spec, _meta2, [{_, _, [fn_name, _, _]}]} | []]} = ast, acc) do
    {ast, [{:spec, fn_name} | acc]}
  end

  defp transverse({:@, _meta, [{:spec, _meta2, [{_, _, [{fn_name, _, _} | _]}]} | _]} = ast, acc) do
    {ast, [{:spec, fn_name} | acc]}
  end

  defp transverse({:@, _meta, [{:spec, _meta2, [{fn_name, _, _}]} | _]} = ast, acc) do
    {ast, [{:spec, fn_name} | acc]}
  end

  defp transverse({:@, _meta, [{:doc, _meta2, _content} | _]} = ast, acc) do
    {ast, [:doc | acc]}
  end

  defp transverse({op, _meta, [{:when, _, [{fn_name, _, _} | _]} | _]} = ast, acc)
       when op in @def_ops do
    {ast, [{op, fn_name} | acc]}
  end

  defp transverse({op, _meta, [{fn_name, _, _part2} | _]} = ast, acc)
       when op in @def_ops do
    {ast, [{op, fn_name} | acc]}
  end

  defp transverse(ast, acc) do
    {ast, acc}
  end

  defp check_errors(attrs) do
    Enum.reduce(attrs, [], fn attr, acc ->
      acc |> check_wrong_order(attr) |> check_name_match(attr)
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
    @spec #{Atom.to_string(fn_name)}
    @doc
    #{Atom.to_string(fn_op)} #{Atom.to_string(fn_name)}
    """

    correct = """
    @doc
    @spec #{Atom.to_string(fn_name)}
    #{Atom.to_string(fn_op)} #{Atom.to_string(fn_name)}
    """

    {:fail,
     %Comment{
       type: :informative,
       name: Constants.solution_doc_spec_order(),
       comment: Constants.solution_doc_spec_order(),
       params: %{
         actual: actual,
         correct: correct
       }
     }}
  end

  defp spec_name_error_msg(attr) do
    {fn_op, fn_name} = attr.definition

    actual = """
    @spec #{Atom.to_string(attr.spec)}
    #{Atom.to_string(fn_op)} #{Atom.to_string(fn_name)}
    """

    correct = """
    @spec #{Atom.to_string(fn_name)}
    #{Atom.to_string(fn_op)} #{Atom.to_string(fn_name)}
    """

    {:fail,
     %Comment{
       type: :informative,
       name: Constants.solution_wrong_spec_name(),
       comment: Constants.solution_wrong_spec_name(),
       params: %{
         correct: correct,
         actual: actual
       }
     }}
  end
end
