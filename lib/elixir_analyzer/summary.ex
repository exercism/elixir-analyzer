defmodule ElixirAnalyzer.Summary do
  @moduledoc """
    Utility functions to format the string to puts the summary in ElixirAnalyzer.
  """

  alias ElixirAnalyzer.Submission

  @doc """
  From the Submission, return a string representation of the Analysis summary
  """
  @spec summary(Submission.t(), map()) :: String.t()
  def summary(s = %Submission{}, params) do
    """
    ElixirAnalyzer Report
    ---------------------

    Exercise: #{params.exercise}
    Status: #{result_to_string(s)}
    Output written to ... #{Path.join(params.output_path, params.output_file)}
    """
  end

  defp result_to_string(s = %Submission{}) do
    case {s.halted, s.analyzed} do
      {true, _} -> "Halted"
      {_, false} -> "Analysis Incomplete"
      {_, true} -> "Analysis Complete"
    end
  end
end
