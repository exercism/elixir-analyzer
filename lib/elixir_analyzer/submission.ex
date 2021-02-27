defmodule ElixirAnalyzer.Submission do
  @moduledoc """
  Module defines a struct which represents the data defined by the result schema for Exercism's Analayzer

  JSON format

  {
    "status": "...",
    "comments": [
      {
        "comment": "elixir.general.some_paramaterised_message",
        "params": { "foo": "param1", "bar": "param2" }
      },
      {
        "comment": "elixir.general.some_paramaterised_message"
      },
      "elixir.general.some_paramaterised_message"
    ]
  }
  The following statuses are valid:

  skipped: Something caused the analysis to be skipped
  approve: To be used when a solution meets critera of a passing solution, comments MAY BE provided for improvement towards optimal.
  disapprove: To be used when a solution can be disapproved as suboptimal and an actionable comment MUST BE provided.
  refer_to_mentor: default status, a comment MAY BE provided.
  """

  @enforce_keys [:code_file, :code_path, :path, :analysis_module]
  defstruct halted: false,
            halt_reason: nil,
            analyzed: false,
            comments: [],
            path: nil,
            code_path: nil,
            code_file: nil,
            code: nil,
            analysis_module: nil

  @type t() :: %__MODULE__{
          halted: boolean,
          halt_reason: String.t() | nil,
          analyzed: boolean,
          comments: list([binary | map]),
          path: String.t(),
          code_path: String.t(),
          code_file: String.t(),
          code: String.t(),
          analysis_module: atom()
        }

  def to_json(submission = %__MODULE__{}) do
    Jason.encode!(%{summary: get_summary(submission), comments: submission.comments})
  end

  @doc false
  def halt(submission = %__MODULE__{}) do
    %{submission | halted: true}
  end

  def set_halt_reason(submission = %__MODULE__{}, reason) when is_binary(reason) do
    %{submission | halt_reason: reason}
  end

  @doc false
  def set_analyzed(submission = %__MODULE__{}, value) when is_boolean(value) do
    %{submission | analyzed: value}
  end

  @doc false
  def append_comment(submission = %__MODULE__{}, meta) when is_map(meta) do
    comment =
      Enum.filter(meta, fn
        {key, _} when key in [:comment, :type, :params] -> true
        _ -> false
      end)

    %{submission | comments: submission.comments ++ [comment]}
  end

  defp get_summary(submission = %__MODULE__{}) do
    if submission.halted do
      submission.halt_reason
    end
  end
end
