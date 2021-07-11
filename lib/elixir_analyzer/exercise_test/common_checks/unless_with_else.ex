defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.UnlessWithElse do
  @moduledoc """
  Reports when an unless clause is used followed by an else clause.

  Common check to be run on every single solution.
  """
  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Comment

  @def_ops [:def, :defp, :defmacro, :defmacrop, :defguard, :defguardp]

  @spec run(Macro.t()) :: [{:pass | :fail | :skip, %Comment{}}]
  def run(ast) do
    {_, issues} = Macro.prewalk(ast, [], &traverse/2)

    # correct_implementation = if_else_implementation()
    # wrong_implementation = issues

    # if else_block? do
    # [
    #   {:fail,
    #    %Comment{
    #      type: :actionable,
    #      comment: Constants.solution_unless_with_else(),
    #      params: %{
    #        expected: correct_implementation,
    #        actual: wrong_implementation
    #      }
    #    }}
    # ]
    # end
  end

  defp traverse({:unless, meta, args} = ast, issues) do
    if else_block?(args) do
      {ast, issues}
    else
      nil
    end
  end

  defp else_block?(args) do
    case else_block_for(args) do
      {:ok, else_block} -> else_block
      nil -> nil
    end
  end

  defp else_block_for(args) when is_list(args) do
    Enum.find_value(args, &find_keyword(&1, :else))
  end

  defp if_else_implementation({:unless, meta, args} = ast) do
    [_, [do: do_block, else: else_block] = block] = args
  end

  defp find_keyword(list, keyword) when is_list(list) do
    if Keyword.has_key?(list, keyword) do
      {:ok, list[keyword]}
    else
      nil
    end
  end

  defp find_keyword(_, _), do: nil
end
