defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.UnlessWithElse do
  @moduledoc """
  Reports when an unless clause is used followed by an else clause.

  Common check to be run on every single solution.
  """
  alias ElixirAnalyzer.Comment
  alias ElixirAnalyzer.Constants

  @spec run(Macro.t()) :: [{:pass | :fail | :skip, %Comment{}}]
  def run(ast) do
    {_ast, else_block} = Macro.prewalk(ast, [], &traverse/2)

    if Enum.empty?(else_block) do
      []
    else
      [
        {:fail,
         %Comment{
           type: :actionable,
           comment: Constants.solution_unless_with_else()
         }}
      ]
    end
  end

  defp traverse({:@, _, [{:unless, _, _}]} = ast, issues) do
    if else_block?(ast) do
      else_block = else_block_for(ast)
      {ast, [else_block | issues]}
    else
      {ast, []}
    end
  end

  defp traverse({:unless, _, _} = ast, issues) do
    if else_block?(ast) do
      else_block = else_block_for(ast)
      {ast, [else_block | issues]}
    else
      {ast, []}
    end
  end

  defp else_block?(ast) do
    case else_block_for(ast) do
      {:ok, _block} -> true
      nil -> false
    end
  end

  defp else_block_for({_atom, _meta, arguments}) when is_list(arguments),
    do: else_block_for(arguments)

  defp else_block_for(do: _do_block, else: else_block), do: {:ok, else_block}

  defp else_block_for(arguments) when is_list(arguments) do
    Enum.find_value(arguments, &find_keyword(&1, :else))
  end

  defp else_block_for(_), do: nil

  defp find_keyword(list, keyword) when is_list(list) do
    if Keyword.has_key?(list, keyword) do
      {:ok, list[keyword]}
    else
      nil
    end
  end

  defp find_keyword(_, _), do: nil
end
