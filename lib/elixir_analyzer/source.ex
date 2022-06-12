defmodule ElixirAnalyzer.Source do
  @moduledoc """
  Represents all the data received: solution code, exemploid, slug and paths
  """
  defstruct [
    :slug,
    :path,
    :submitted_files,
    :code_string,
    :code_ast,
    :exercise_type,
    :exemploid_files,
    :exemploid_string,
    :exemploid_ast
  ]

  @type t() :: %__MODULE__{
          slug: String.t(),
          path: String.t(),
          submitted_files: [String.t()],
          code_string: String.t(),
          code_ast: Macro.t(),
          exercise_type: :concept | :practice,
          exemploid_files: [String.t()],
          exemploid_string: String.t(),
          exemploid_ast: Macro.t()
        }
end
