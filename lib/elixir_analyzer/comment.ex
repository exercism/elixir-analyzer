defmodule ElixirAnalyzer.Comment do
  @moduledoc """
  Represents a single analysis comment
  (see https://github.com/exercism/docs/blob/main/building/tooling/analyzers/interface.md#comments)
  """

  defstruct status: :test, name: nil, comment: nil, type: nil, suppress_if: false, params: nil

  @type t :: %__MODULE__{
          name: String.t(),
          comment: String.t(),
          type: :essential | :actionable | :informative | :celebratory,
          status: :skip | :test,
          suppress_if: false | {String.t(), :pass | :fail},
          params: map()
        }
end
