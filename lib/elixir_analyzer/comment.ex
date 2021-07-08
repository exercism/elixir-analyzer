defmodule ElixirAnalyzer.Comment do
  defstruct status: :test, name: nil, comment: nil, type: nil, suppress_if: nil, params: nil

  @type t :: %__MODULE__{
          name: String.t(),
          comment: String.t(),
          type: :essential | :actionable | :informative | :celebratory,
          status: :skip | :test,
          suppress_if: false | {String.t(), :pass | :fail}
        }
end
