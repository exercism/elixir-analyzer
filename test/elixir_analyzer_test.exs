defmodule ElixirAnalyzerTest do
  use ExUnit.Case
  doctest ElixirAnalyzer

  alias ElixirAnalyzer.Submission

  describe "ElixirAnalyzer" do
    @options [puts_summary: false, write_results: false]

    # @tag :pending
    test "approved solution" do
      exercise = "two-fer"
      path = "./test_data/two_fer/approved_solution/"
      analyzed_exercise = ElixirAnalyzer.analyze_exercise(exercise, path, @options)
      expected_output = """
        {"comments":[],"status":"approve"}
        """

      assert Submission.to_json(analyzed_exercise) == String.trim(expected_output)
    end

    # @tag :pending
    test "approved solution with comments" do
      exercise = "two-fer"
      path = "./test_data/two_fer/referred_solution/"
      analyzed_exercise = ElixirAnalyzer.analyze_exercise(exercise, path, @options)
      expected_output = """
        {\"comments\":[\"elixir.solution.use_module_doc\",\"elixir.solution.raise_fn_clause_error\",\"elixir.solution.use_specification\"],\"status\":\"approve\"}
        """

      assert Submission.to_json(analyzed_exercise) == String.trim(expected_output)
    end

    # @tag :pending
    test "error solution" do
      exercise = "two-fer"
      path = "./test_data/two_fer/error_solution/"
      analyzed_exercise = ElixirAnalyzer.analyze_exercise(exercise, path, @options)
      expected_output = """
        {"comments":[{"comment":"elixir.general.parsing_error","params":{"error":"missing terminator: end (for \\"do\\" starting at line 1)","line":14,"token":""}}],"status":"refer_to_mentor"}
        """

      assert Submission.to_json(analyzed_exercise) == String.trim(expected_output)
    end
  end
end
