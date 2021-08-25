defmodule ElixirAnalyzerTest do
  use ExUnit.Case
  doctest ElixirAnalyzer

  import ExUnit.CaptureLog

  alias ElixirAnalyzer.Submission

  describe "ElixirAnalyzer" do
    @options [puts_summary: false, write_results: false]

    # @tag :pending
    test "solution with no comments" do
      exercise = "two-fer"
      path = "./test_data/two_fer/perfect_solution/"
      analyzed_exercise = ElixirAnalyzer.analyze_exercise(exercise, path, path, @options)

      expected_output = """
      {\"comments\":[],\"summary\":\"Submission analyzed. No automated suggestions found.\"}
      """

      assert Submission.to_json(analyzed_exercise) == String.trim(expected_output)
    end

    # @tag :pending
    test "referred solution with comments" do
      exercise = "two-fer"
      path = "./test_data/two_fer/imperfect_solution/"
      analyzed_exercise = ElixirAnalyzer.analyze_exercise(exercise, path, path, @options)

      expected_output =
        "{\"comments\":[{\"comment\":\"elixir.solution.raise_fn_clause_error\",\"type\":\"actionable\"},{\"comment\":\"elixir.two-fer.use_of_function_header\",\"type\":\"actionable\"},{\"comment\":\"elixir.solution.use_specification\",\"type\":\"actionable\"},{\"comment\":\"elixir.solution.variable_name_snake_case\",\"params\":{\"actual\":\"_nameInPascalCase\",\"expected\":\"_name_in_pascal_case\"},\"type\":\"actionable\"},{\"comment\":\"elixir.solution.module_attribute_name_snake_case\",\"params\":{\"actual\":\"someUnusedModuleAttribute\",\"expected\":\"some_unused_module_attribute\"},\"type\":\"actionable\"},{\"comment\":\"elixir.solution.module_pascal_case\",\"params\":{\"actual\":\"My_empty_module\",\"expected\":\"MyEmptyModule\"},\"type\":\"actionable\"},{\"comment\":\"elixir.solution.use_module_doc\",\"type\":\"informative\"},{\"comment\":\"elixir.solution.indentation\",\"type\":\"informative\"}],\"summary\":\"Check the comments for some code suggestions. 📣\"}"

      assert Submission.to_json(analyzed_exercise) == expected_output
    end

    # @tag :pending
    test "error solution" do
      exercise = "two-fer"
      path = "./test_data/two_fer/error_solution/"

      capture_log(fn ->
        analyzed_exercise = ElixirAnalyzer.analyze_exercise(exercise, path, path, @options)

        expected_output = """
        {\"comments\":[{\"comment\":\"elixir.general.parsing_error\",\"params\":{\"error\":\"missing terminator: end (for \\\"do\\\" starting at line 1)\",\"line\":14},\"type\":\"essential\"}],\"summary\":\"Check the comments for things to fix. 🛠\"}
        """

        assert Submission.to_json(analyzed_exercise) == String.trim(expected_output)
      end)
    end

    test "missing file solution" do
      exercise = "two-fer"
      path = "./test_data/two_fer/missing_file_solution/"
      analyzed_exercise = ElixirAnalyzer.analyze_exercise(exercise, path, path, @options)

      expected_output = """
      {\"comments\":[{\"comment\":\"elixir.general.file_not_found\",\"params\":{\"file_name\":\"two_fer.ex\",\"path\":\"./test_data/two_fer/missing_file_solution/\"},\"type\":\"essential\"}],\"summary\":\"Check the comments for things to fix. 🛠\"}
      """

      assert Submission.to_json(analyzed_exercise) == String.trim(expected_output)
    end

    test "solution for an exercise with no analyzer module uses the default module" do
      exercise = "not-a-real-exercise"
      path = "./test_data/two_fer/imperfect_solution/"

      capture_log(fn ->
        analyzed_exercise = ElixirAnalyzer.analyze_exercise(exercise, path, path, @options)

        expected_output = """
        {\"comments\":[{\"comment\":\"elixir.solution.variable_name_snake_case\",\"params\":{\"actual\":\"_nameInPascalCase\",\"expected\":\"_name_in_pascal_case\"},\"type\":\"actionable\"},{\"comment\":\"elixir.solution.module_attribute_name_snake_case\",\"params\":{\"actual\":\"someUnusedModuleAttribute\",\"expected\":\"some_unused_module_attribute\"},\"type\":\"actionable\"},{\"comment\":\"elixir.solution.module_pascal_case\",\"params\":{\"actual\":\"My_empty_module\",\"expected\":\"MyEmptyModule\"},\"type\":\"actionable\"},{\"comment\":\"elixir.solution.indentation\",\"type\":\"informative\"}],\"summary\":\"Check the comments for some code suggestions. 📣\"}
        """

        assert Submission.to_json(analyzed_exercise) == String.trim(expected_output)
      end)
    end
  end

  describe "config" do
    test "every available exercise test suite assigned to an exercise slug in the config" do
      {:ok, modules} = :application.get_key(:elixir_analyzer, :modules)

      all_available_test_suites =
        Enum.filter(modules, fn module ->
          module
          |> to_string
          |> String.starts_with?("Elixir.ElixirAnalyzer.TestSuite.")
        end)

      test_suites_referenced_in_config =
        Enum.map(ElixirAnalyzer.default_exercise_config(), fn {_, value} ->
          value.analyzer_module
        end)

      unused_available_test_suites = all_available_test_suites -- test_suites_referenced_in_config

      unused_available_test_suites =
        unused_available_test_suites -- [ElixirAnalyzer.TestSuite.Default]

      unavailable_test_suites_referenced_in_config =
        test_suites_referenced_in_config -- all_available_test_suites

      assert unused_available_test_suites == []
      assert unavailable_test_suites_referenced_in_config == []
    end
  end
end
