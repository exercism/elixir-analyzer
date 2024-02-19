defmodule ElixirAnalyzer.Submission do
  @moduledoc """
  Module defines a struct which represents the data defined by the result schema for Exercism's Analayzer

  JSON format

  {
    "summary": "...",
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
  """

  alias ElixirAnalyzer.Comment
  alias ElixirAnalyzer.Source
  alias ElixirAnalyzer.Constants

  @enforce_keys [:source, :analysis_module]
  defstruct halted: false,
            halt_reason: nil,
            analyzed: false,
            comments: [],
            source: %Source{},
            analysis_module: nil

  @type t() :: %__MODULE__{
          halted: boolean,
          halt_reason: String.t() | nil,
          analyzed: boolean,
          comments: list([Comment.t()]),
          source: Source.t(),
          analysis_module: atom()
        }

  def to_json(%__MODULE__{} = submission) do
    Jason.encode!(%{summary: get_summary(submission), comments: submission.comments})
  end

  @doc false
  def halt(%__MODULE__{} = submission) do
    %{submission | halted: true}
  end

  def set_halt_reason(%__MODULE__{} = submission, reason) when is_binary(reason) do
    %{submission | halt_reason: reason}
  end

  @doc false
  def set_analyzed(%__MODULE__{} = submission, value) when is_boolean(value) do
    %{submission | analyzed: value}
  end

  @doc false
  def append_comment(%__MODULE__{} = submission, %Comment{} = comment) do
    comment =
      comment
      |> Map.from_struct()
      |> Enum.filter(fn
        {key, _} when key in [:comment, :type] -> true
        {key, value} when key in [:params] and value != nil -> true
        _ -> false
      end)
      |> Enum.into(%{})

    comments =
      if Enum.member?(submission.comments, comment) do
        submission.comments
      else
        submission.comments ++ [comment]
      end

    %{submission | comments: comments}
  end

  @comment_types ~w{celebratory essential actionable informative}a

  @doc """
  Sort submission comments by importance (`:essential` to `:celebratory`)
  """
  def sort_comments(%__MODULE__{comments: comments} = submission) do
    comments =
      Enum.sort_by(comments, fn %{type: type} ->
        Enum.find_index(@comment_types, &(&1 == type))
      end)

    %{submission | comments: comments}
  end

  def append_feedback_request_comment(%__MODULE__{comments: comments} = submission) do
    frequencies = get_type_frequencies_in_comments(comments)

    comments =
      if frequencies.essential + frequencies.actionable > 0 do
        comments ++
          [
            %{
              type: :informative,
              comment: Constants.general_feedback_request(),
              params: %{
                mentoring_request_url:
                  "https://exercism.org/tracks/elixir/exercises/#{submission.source.slug}/mentor_discussions"
              }
            }
          ]
      else
        comments
      end

    %{submission | comments: comments}
  end

  defp get_summary(%__MODULE__{halted: true, comments: comments} = submission)
       when comments == [] do
    case submission.halt_reason do
      nil -> "Analysis was halted."
      _ -> "Analysis was halted. #{submission.halt_reason}"
    end
  end

  defp get_summary(%__MODULE__{comments: comments}) do
    summary_response(get_type_frequencies_in_comments(comments))
  end

  @default_type_frequencies @comment_types |> Enum.map(&{&1, 0}) |> Enum.into(%{})
  defp get_type_frequencies_in_comments(comments) do
    type_frequencies_in_comments = Enum.frequencies_by(comments, fn comment -> comment.type end)

    @default_type_frequencies
    |> Map.merge(type_frequencies_in_comments)
  end

  @nbsp <<0xC2, 0xA0>>

  # Essential
  defp summary_response(%{essential: count}) when count > 0,
    do: "Check the comments for things to fix.#{@nbsp}🛠"

  # Actionable
  defp summary_response(%{actionable: count}) when count > 0,
    do: "Check the comments for some suggestions.#{@nbsp}📣"

  # Informative
  defp summary_response(%{informative: count}) when count > 0,
    do: "Check the comments for some things to learn.#{@nbsp}📖"

  # Celebratory
  defp summary_response(%{celebratory: count}) when count > 0,
    do: "You're doing something right.#{@nbsp}🎉"

  defp summary_response(_),
    do: "Submission analyzed. No automated suggestions found."
end
