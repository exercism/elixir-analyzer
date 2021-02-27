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

  defp get_summary(submission = %__MODULE__{halted: true, comments: comments})
       when length(comments) == 0 do
    case submission.halt_reason do
      nil -> "Analysis was halted."
      _ -> "Analysis was halted. #{submission.halt_reason}"
    end
  end

  @comment_types ~w{celebratory essential actionable informative}a
  @default_type_frequencies @comment_types |> Enum.map(&{&1, 0}) |> Enum.into(%{})

  defp get_summary(%__MODULE__{comments: comments}) do
    type_frequencies_in_comments = Enum.frequencies_by(comments, fn comment -> comment.type end)

    summary =
      @default_type_frequencies
      |> Map.merge(type_frequencies_in_comments)
      |> build_summary_response()

    case summary do
      nil -> "Submission analyzed. No automated suggestions. Great work! 🚀"
      _ -> summary
    end
  end

  defp build_summary_response(type_frequencies, keys_to_build \\ @comment_types, acc \\ nil)
  defp build_summary_response(_type_frequencies, [], acc), do: acc

  # Celebratory
  defp build_summary_response(t = %{celebratory: 0}, [:celebratory | rest], acc),
    do: build_summary_response(t, rest, acc)

  defp build_summary_response(t = %{celebratory: _}, [:celebratory | rest], _acc),
    do: build_summary_response(t, rest, "🎉")

  # Essential
  defp build_summary_response(t = %{essential: 0}, [:essential | rest], acc),
    do: build_summary_response(t, rest, acc)

  defp build_summary_response(_, [:essential | _], acc),
    do: "#{acc} Check out the comments for things to fix." |> String.trim_leading()

  # Actionable
  defp build_summary_response(t = %{actionable: 0}, [:actionable | rest], acc),
    do: build_summary_response(t, rest, acc)

  defp build_summary_response(_, [:actionable | _], acc),
    do: "#{acc} Check out the comments for some code suggestions." |> String.trim_leading()

  # Informative
  defp build_summary_response(t = %{informative: 0}, [:informative | rest], acc),
    do: build_summary_response(t, rest, acc)

  defp build_summary_response(_, [:informative | _], acc),
    do: "#{acc} Check out the comments for some things to learn." |> String.trim_leading()
end
