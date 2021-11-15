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
    solution_indentation: "elixir.solution.indentation",
    solution_debug_functions: "elixir.solution.debug_functions",
    solution_last_line_assignment: "elixir.solution.last_line_assignment",
    solution_compiler_warnings: "elixir.solution.compiler_warnings",
    solution_def_with_is: "elixir.solution.def_with_is",
    solution_defguard_with_question_mark: "elixir.solution.defguard_with_question_mark",
    solution_defmacro_with_is_and_question_mark:
      "elixir.solution.defmacro_with_is_and_question_mark",
    solution_same_as_exemplar: "elixir.solution.same_as_exemplar",
    solution_list_prepend_head: "elixir.solution.list_prepend_head",
    solution_no_integer_literal: "elixir.solution.no_integer_literal",
    solution_boilerplate_comment: "elixir.solution.boilerplate_comment",
    solution_todo_comment: "elixir.solution.todo_comment",
    solution_private_helper_functions: "elixir.solution.private_helper_functions",
    solution_unless_with_else: "elixir.solution.unless_with_else",
    solution_use_function_capture: "elixir.solution.use_function_capture",

    # Concept exercises

    # Bird Count Comments
    bird_count_use_recursion: "elixir.bird-count.use_recursion",

    # Boutique Inventory Comments
    boutique_inventory_use_enum_sort_by: "elixir.boutique-inventory.use_enum_sort_by",
    boutique_inventory_use_enum_filter_or_enum_reject:
      "elixir.boutique-inventory.use_enum_filter_or_enum_reject",
    boutique_inventory_use_enum_reduce: "elixir.boutique-inventory.use_enum_reduce",

    # Boutique Suggestions Comments
    boutique_suggestions_use_list_comprehensions:
      "elixir.boutique-suggestions.use_list_comprehensions",

    # Chessboard Comments
    chessboard_function_reuse: "elixir.chessboard.function_reuse",
    chessboard_change_codepoint_to_string_directly:
      "elixir.chessboard.change_codepoint_to_string_directly",

    # Captains Log Comments
    captains_log_use_enum_random: "elixir.captains-log.use_enum_random",
    captains_log_use_rand_uniform: "elixir.captains-log.use_rand_uniform",
    captains_log_use_io_lib: "elixir.captains-log.use_io_lib",

    # File Sniffer Comments
    file_sniffer_use_pattern_matching: "elixir.file-sniffer.use_pattern_matching",

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
    high_score_use_map_update: "elixir.high-score.use_map_update",

    # High School Sweetheart Comments
    high_school_sweetheart_function_reuse: "elixir.high-school-sweetheart.function_reuse",

    # Language List Comments
    language_list_do_not_use_enum: "elixir.language-list.do_not_use_enum",

    # Lasagna Comments
    lasagna_function_reuse: "elixir.lasagna.function_reuse",

    # Leap Comments
    leap_erlang_calendar: "elixir.leap.erlang_calendar",

    # Library Fees Comments
    library_fees_function_reuse: "elixir.library-fees.function_reuse",

    # Log Level Comments
    log_level_use_cond: "elixir.log-level.use_cond",

    # Name Badge Comments
    name_badge_use_if: "elixir.name-badge.use_if",

    # Need For Speed Comments
    need_for_speed_import_IO_with_only: "elixir.need-for-speed.import_IO_with_only",
    need_for_speed_import_ANSI_with_except: "elixir.need-for-speed.import_ANSI_with_except",
    need_for_speed_do_not_modify_code: "elixir.need-for-speed.do_not_modify_code",

    # Newsletter Comments
    newsletter_close_log_returns_implicitly: "elixir.newsletter.close_log_returns_implicitly",
    newsletter_log_sent_email_prefer_io_puts: "elixir.newsletter.log_sent_email_prefer_io_puts",
    newsletter_log_sent_email_returns_implicitly:
      "elixir.newsletter.log_sent_email_returns_implicitly",
    newsletter_send_newsletter_returns_implicitly:
      "elixir.newsletter.send_newsletter_returns_implicitly",
    newsletter_open_log_uses_option_write: "elixir.newsletter.open_log_uses_option_write",
    newsletter_send_newsletter_reuses_functions:
      "elixir.newsletter.send_newsletter_reuses_functions",

    # New Passport Comments
    new_passport_use_with: "elixir.new-passport.use_with",
    new_passport_do_not_modify_code: "elixir.new-passport.do_not_modify_code",

    # Pacman Rules Comments
    pacman_rules_use_strictly_boolean_operators:
      "elixir.pacman-rules.use_strictly_boolean_operators",

    # RPG Character Sheet
    rpg_character_sheet_welcome_ends_with_IO_puts:
      "elixir.rpg-character-sheet.welcome_ends_with_IO_puts",
    rpg_character_sheet_run_uses_other_functions:
      "elixir.rpg-character-sheet.run_uses_other_functions",
    rpg_character_sheet_run_ends_with_IO_inspect:
      "elixir.rpg-character-sheet.ends_with_IO_inspect",
    rpg_character_sheet_IO_inspect_uses_label: "elixir.rpg-character-sheet.IO_inspect_uses_label",

    # RPN Calculator Inspection
    rpn_calculator_inspection_use_start_link: "elixir.rpn-calculator-inspection.use_start_link",

    # RPN Calculator Output
    rpn_calculator_output_try_rescue_else_after:
      "elixir.rpn-calculator-output.try_rescue_else_after",
    rpn_calculator_output_open_before_try: "elixir.rpn-calculator-output.open_before_try",
    rpn_calculator_output_write_in_try: "elixir.rpn-calculator-output.write_in_try",
    rpn_calculator_output_output_in_else: "elixir.rpn-calculator-output.output_in_else",
    rpn_calculator_output_close_in_after: "elixir.rpn-calculator-output.close_in_after",

    # Take A Number Comments
    take_a_number_do_not_use_abstractions: "elixir.take-a-number.do_not_use_abstractions",

    # Top Secret Comments
    top_secret_function_reuse: "elixir.top-secret.function_reuse",

    # Wine Cellar Comments
    wine_cellar_use_keyword_get_values: "elixir.wine-cellar.use_keyword_get_values",

    # Practice exercises

    # Accumulate Comments
    accumulate_use_recursion: "elixir.accumulate.use_recursion",

    # List Ops Comments
    list_ops_do_not_use_list_functions: "elixir.list-ops.do_not_use_list_functions",

    # Strain Comments
    strain_use_recursion: "elixir.strain.use_recursion",

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
