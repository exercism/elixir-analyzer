defmodule ElixirAnalyzerTest do
  use ExUnit.Case
  doctest ElixirAnalyzer

  alias ElixirAnalyzer.Submission

  describe "test ElixirAnalyzer" do
    @options [puts_summary: false, write_results: false]

    test "passing solution" do
      exercise = "two-fer"
      path = "./test_data/two_fer/passing_solution/"
      analyzed_exercise = ElixirAnalyzer.analyze_exercise(exercise, path, @options)
      expected_output = """
        {"comments":["elixir.general.refer_to_mentor"],"status":"refer_to_mentor"}
        """

      assert Submission.to_json(analyzed_exercise) == String.trim(expected_output)
    end

    test "failing solution" do
      exercise = "two-fer"
      path = "./test_data/two_fer/failing_solution/"
      analyzed_exercise = ElixirAnalyzer.analyze_exercise(exercise, path, @options)
      expected_output = """
        {"comments":["elixir.general.refer_to_mentor","elixir.solution.missing_module_doc","elixir.two_fer.no_default_param","elixir.two_fer.no_specification"],"status":"refer_to_mentor"}
        """

      assert Submission.to_json(analyzed_exercise) == String.trim(expected_output)
    end

    test "error solution" do
      exercise = "two-fer"
      path = "./test_data/two_fer/error_solution/"
      analyzed_exercise = ElixirAnalyzer.analyze_exercise(exercise, path, @options)
      expected_output = """
        {"comments":["elixir.general.refer_to_mentor",{"comment":"elixir.analysis.quote_error","params":{"error":"missing terminator: end (for \\"do\\" starting at line 1)","line":14,"token":""}}],"status":"refer_to_mentor"}
        """

      assert Submission.to_json(analyzed_exercise) == String.trim(expected_output)
    end
  end
end
