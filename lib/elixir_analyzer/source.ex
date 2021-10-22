defmodule ElixirAnalyzer.Source do
  defstruct [
    :slug,
    :path,
    :code_path,
    :code_string,
    :code_ast,
    :exercice_type,
    :exemploid_path,
    :exemploid_string,
    :exemploid_ast
  ]

  @type t() :: %__MODULE__{
          slug: String.t(),
          path: String.t(),
          code_path: String.t(),
          code_string: String.t(),
          code_ast: Macro.t(),
          exercice_type: :concept | :practice,
          exemploid_path: String.t(),
          exemploid_string: String.t(),
          exemploid_ast: Macro.t()
        }
end
