defmodule ElixirAnalyzer.Submission do
  @moduledoc """
  Module defines a struct which represents the data defined by the result schema for Exercism's Analayzer

  JSON format

  {
    "status": "...",
    "comments": [
      {
        "comment": "ruby.general.some_paramaterised_message",
        "params": { "foo": "param1", "bar": "param2" }
      },
      {
        "comment": "ruby.general.some_paramaterised_message"
      },
      "ruby.general.some_paramaterised_message"
    ]
  }
  The following statuses are valid:

  approve: To be used when a solution meets critera of a passing solution, comments MAY BE provided for improvement towards optimal.
  disapprove: To be used when a solution can be disapproved as suboptimal and an actionable comment MUST BE provided.
  refer_to_mentor: default status, a comment MAY BE provided.
  """

  @status_map %{
    :approve => "approve",
    :disapprove => "disapprove",
    :refer => "refer_to_mentor"
  }

  @enforce_keys [:code_file, :code_path, :path, :analysis_module]
  defstruct halted: false,
            analyzed: false,
            status: nil,
            comments: [],
            path: nil,
            code_path: nil,
            code_file: nil,
            code: nil,
            analysis_module: nil,
            final: false

  @type t() :: %__MODULE__{
          halted: boolean,
          analyzed: boolean,
          status: atom(),
          comments: list([binary | map]),
          path: String.t(),
          code_path: String.t(),
          code_file: String.t(),
          code: String.t(),
          analysis_module: atom(),
          final: boolean
        }

  def to_json(r = %__MODULE__{}) do
    Jason.encode!(%{status: @status_map[r.status], comments: r.comments})
  end

  def approve(r = %__MODULE__{status: nil}), do: %{r | status: :approve}
  def approve(r), do: r

  def disapprove(r = %__MODULE__{status: s}) when s in [nil, :approve],
    do: %{r | status: :disapprove}

  def disapprove(r), do: r

  def refer(r = %__MODULE__{}), do: %{r | status: :refer}

  def finalize(r = %__MODULE__{status: nil, final: false}),
    do: %{r | status: :refer} |> finalize()

  def finalize(r = %__MODULE__{final: false}) do
    Map.put(r, :final, true)
  end

  def prepend_comment(r = %__MODULE__{}, comment) when is_binary(comment) do
    do_prepend_comment(r, comment)
  end

  def prepend_comment(r = %__MODULE__{}, {comment}) when is_binary(comment) do
    do_prepend_comment(r, %{"comment" => comment})
  end

  def prepend_comment(r = %__MODULE__{}, {comment, params})
      when is_binary(comment) and is_map(params) do
    params
    |> Map.keys()
    |> Enum.all?(fn key -> Kernel.is_atom(key) or Kernel.is_binary(key) end)
    |> case do
      false ->
        raise ArgumentError, "key type must be atom or binary"

      true ->
        do_prepend_comment(r, %{"comment" => comment, "params" => params})
    end
  end

  defp do_prepend_comment(r = %__MODULE__{}, comment) do
    %{r | comments: [comment | r.comments]}
  end

  def append_comment(r = %__MODULE__{}, comment) when is_binary(comment) do
    do_append_comment(r, comment)
  end

  def append_comment(r = %__MODULE__{}, {comment}) when is_binary(comment) do
    do_append_comment(r, %{"comment" => comment})
  end

  def append_comment(r = %__MODULE__{}, {comment, params})
      when is_binary(comment) and is_map(params) do
    Map.keys(params)
    |> Enum.all?(fn key -> Kernel.is_atom(key) or Kernel.is_binary(key) end)
    |> case do
      false ->
        raise ArgumentError, "key type must be atom or binary"

      true ->
        do_append_comment(r, %{"comment" => comment, "params" => params})
    end
  end

  defp do_append_comment(r = %__MODULE__{}, comment) do
    %{r | comments: [comment | Enum.reverse(r.comments)] |> Enum.reverse()}
  end

  def halt(r = %__MODULE__{}) do
    %{r | halted: true}
  end

  def set_analyzed(r = %__MODULE__{}, value) when is_boolean(value) do
    %{r | analyzed: value}
  end
end
