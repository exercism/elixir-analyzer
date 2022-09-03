defmodule ElixirAnalyzer.Comment do
  @moduledoc """
  Represents a single analysis comment
  (see https://github.com/exercism/docs/blob/main/building/tooling/analyzers/interface.md#comments)
  """

  defstruct status: :test, name: nil, comment: nil, type: nil, suppress_if: [], params: nil

  @type t :: %__MODULE__{
          name: String.t(),
          comment: String.t(),
          type: :essential | :actionable | :informative | :celebratory,
          suppress_if: [{String.t(), :pass | :fail}],
          params: map() | nil
        }

  @supported_types ~w(essential actionable informative celebratory)a

  @spec supported_type?(atom()) :: boolean()
  def supported_type?(type) do
    type in @supported_types
  end

  @spec supported_types() :: list(atom())
  def supported_types do
    @supported_types
  end
end
