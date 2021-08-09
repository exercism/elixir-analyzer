defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.Indentation do
  @moduledoc """
  Reports if tabs were used for indentation.
  """

  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Comment

  @spec run(Macro.t(), String.t()) :: [{:pass | :fail | :skip, %Comment{}}]
  def run(ast, string) do
    if uses_tabs_for_indentation?(ast, string) do
      [
        {:fail,
         %Comment{
           type: :informative,
           comment: Constants.solution_indentation()
         }}
      ]
    else
      []
    end
  end

  defp uses_tabs_for_indentation?(ast, string) do
    count_tabs(string) > count_tabs(Macro.to_string(ast))
  end

  defp count_tabs(string) do
    string
    |> String.replace("\\t", "\t")
    |> String.graphemes()
    |> Enum.count(&(&1 == "\t"))
  end
end
