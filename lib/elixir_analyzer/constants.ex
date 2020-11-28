defmodule ElixirAnalyzer.Constants do
  @constants [
    # Status Comments
    # status_approve: "elixir.status.approve",
    # status_disapprove: "elixir.status.disapprove",
    # status_refer_to_mentor: "elixir.status.refer_to_mentor",

    # General Error Comments
    general_file_not_found: "elixir.general.file_not_found",
    general_parsing_error: "elixir.general.parsing_error",

    # General Solution Error / Warning Comments
    solution_use_moduledoc: "elixir.solution.use_module_doc",
    solution_use_specification: "elixir.solution.use_specification",
    solution_raise_fn_clause_error: "elixir.solution.raise_fn_clause_error",

    # Two-fer Error Comments
    two_fer_use_default_parameter: "elixir.two-fer.use_default_param",
    two_fer_use_guards: "elixir.two-fer.use_guards",
    two_fer_use_string_interpolation: "elixir.two-fer.use_string_interpolation",
    two_fer_wrong_specification: "elixir.two-fer.wrong_specification",
    two_fer_use_function_level_guard: "elixir.two_fer.use_function_level_guard",
    two_fer_use_of_aux_functions: "elixir.two_fer.use_of_aux_functions",
    two_fer_use_of_function_header: "elixir.two_fer.use_of_function_header",
    pacman_rules_use_strictly_boolean_operators:
      "elixir.pacman_rules.use_strictly_boolean_operators"
  ]

  for {constant, markdown} <- @constants do
    def unquote(constant)(), do: unquote(markdown)
  end

  def list_of_all_comments() do
    Enum.map(@constants, &Kernel.elem(&1, 1))
  end
end
