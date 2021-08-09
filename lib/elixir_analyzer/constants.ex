defmodule ElixirAnalyzer.Constants do
  @moduledoc """
  A list of Elixir analyzer comments, in the format:
  ```
  elixir.[directory].[filename]
  ```

  `[directory]` must correspond to a directory in https://github.com/exercism/website-copy/tree/main/analyzer-comments/elixir
  and `[filename].md` must be a file in that directory.
  """

  @constants [
    # General Error Comments
    general_file_not_found: "elixir.general.file_not_found",
    general_parsing_error: "elixir.general.parsing_error",

    # General Solution Error / Warning Comments
    solution_use_moduledoc: "elixir.solution.use_module_doc",
    solution_use_specification: "elixir.solution.use_specification",
    solution_raise_fn_clause_error: "elixir.solution.raise_fn_clause_error",
    solution_module_attribute_name_snake_case: "elixir.solution.module_attribute_name_snake_case",
    solution_module_pascal_case: "elixir.solution.module_pascal_case",
    solution_function_name_snake_case: "elixir.solution.function_name_snake_case",
    solution_variable_name_snake_case: "elixir.solution.variable_name_snake_case",

    # Concept exercises

    # Bird Count Comments
    bird_count_use_recursion: "elixir.bird-count.use_recursion",

    # Boutique Suggestions Comments
    boutique_suggestions_use_list_comprehensions:
      "elixir.boutique-suggestions.use_list_comprehensions",

    # Freelancer Rates Comments
    freelancer_rates_apply_discount_function_reuse:
      "elixir.freelancer-rates.apply_discount_function_reuse",

    # German Sysadmin Comments
    german_sysadmin_no_string: "elixir.german-sysadmin.no_string",
    german_sysadmin_use_case: "elixir.german-sysadmin.use_case",

    # Guessing Game Comments
    guessing_game_use_default_argument: "elixir.guessing-game.use_default_argument",
    guessing_game_use_multiple_clause_functions:
      "elixir.guessing-game.use_multiple_clause_functions",
    guessing_game_use_guards: "elixir.guessing-game.use_guards",

    # High Score Comments
    high_score_use_module_attribute: "elixir.high-score.use_module_attribute",
    high_score_use_default_argument_with_module_attribute:
      "elixir.high-score.use_default_argument_with_module_attribute",

    # Lasagna Comments
    lasagna_function_reuse: "elixir.lasagna.function_reuse",

    # Pacman Rules Comments
    pacman_rules_use_strictly_boolean_operators:
      "elixir.pacman-rules.use_strictly_boolean_operators",

    # Take A Number Comments
    take_a_number_do_not_use_abstractions: "elixir.take-a-number.do_not_use_abstractions",
    # Name Badge Comments
    name_badge_use_if: "elixir.name-badge.use_if",

    # Need For Speed Comments
    need_for_speed_import_IO_with_only: "elixir.need-for-speed.import_IO_with_only",
    need_for_speed_import_ANSI_with_except: "elixir.need-for-speed.import_ANSI_with_except",
    need_for_speed_do_not_modify_code: "elixir.need-for-speed.do_not_modify_code",

    # Practice exercises

    # Accumulate Comments
    accumulate_use_recursion: "elixir.accumulate.use_recursion",

    # Square Root Comments
    square_root_do_not_use_built_in_sqrt: "elixir.square-root.do_not_use_built_in_sqrt",

    # Two-fer Error Comments
    two_fer_use_default_parameter: "elixir.two-fer.use_default_param",
    two_fer_use_guards: "elixir.two-fer.use_guards",
    two_fer_use_string_interpolation: "elixir.two-fer.use_string_interpolation",
    two_fer_wrong_specification: "elixir.two-fer.wrong_specification",
    two_fer_use_function_level_guard: "elixir.two-fer.use_function_level_guard",
    two_fer_use_of_aux_functions: "elixir.two-fer.use_of_aux_functions",
    two_fer_use_of_function_header: "elixir.two-fer.use_of_function_header"
  ]

  for {constant, markdown} <- @constants do
    def unquote(constant)(), do: unquote(markdown)
  end

  def list_of_all_comments() do
    Enum.map(@constants, &Kernel.elem(&1, 1))
  end
end
