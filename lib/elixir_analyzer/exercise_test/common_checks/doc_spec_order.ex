defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.DocSpecOrder do
  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Comment

  @moduledoc """
  Report the first function/macro/guard where @spec module attribute comes before the
  @doc module attribute

  Common check to be run on every single solution.
  """

  @def_ops [:def, :defp, :defmacro, :defmacrop, :defguard, :defguardp]

  @annotations [:spec, :doc]

  def run(ast) do
    {_, attrs} = Macro.prewalk(ast, [], &transverse/2)

    error_msg =
      {:fail,
       %Comment{
         type: :informative,
         name: Constants.solution_doc_spec_order(),
         comment: Constants.solution_doc_spec_order()
       }}

    attrs =
      attrs
      |> Enum.reverse()
      |> Enum.chunk_by(&(&1 in @def_ops))

    Enum.reduce_while(attrs, [], fn
      [:spec, :doc], acc -> {:halt, [error_msg | acc]}
      _el, acc -> {:cont, acc}
    end)
  end

  defp transverse({:@, _meta, [{attr, _meta2, _content}]} = ast, acc) when attr in @annotations do
    {ast, [attr | acc]}
  end

  defp transverse({op, _meta, _} = ast, acc)
       when op in @def_ops do
    {ast, [op | acc]}
  end

  defp transverse(ast, acc) do
    {ast, acc}
  end
end
