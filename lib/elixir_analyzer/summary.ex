defmodule ElixirAnalyzer.Summary do
  @moduledoc """
    Utility functions to format the string to puts the summary in ElixirAnalyzer.
  """

  alias ElixirAnalyzer.Submission

  @doc """
  From the Submission, return a string represenation of the summary of the Analysis
  """
  @spec summary(Submission.t(), map()) :: String.t()
  def summary(s = %Submission{}, params) do
    """
    #{params.exercise} analysis ... #{result_to_string(:halted, s)}!

    Analysis ... #{result_to_string(:analyzed, s)}
    Output written to ... #{params.path}#{params.output_file}
    """
  end

  defp result_to_string(:halted, s = %Submission{}) do
    cond do
      s.halted -> "Halted"
      true -> "Completed"
    end
  end

  defp result_to_string(:analyzed, s = %Submission{}) do
    cond do
      s.analyzed -> "Analysis Complete"
      true -> "Analysis Error"
    end
  end
end
