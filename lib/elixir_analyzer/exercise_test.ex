defmodule ElixirAnalyzer.ExerciseTest do
  @moduledoc false

  alias ElixirAnalyzer.ExerciseTest.Feature.Compiler, as: FeatureCompiler
  alias ElixirAnalyzer.ExerciseTest.AssertCall.Compiler, as: AssertCallCompiler
  alias ElixirAnalyzer.ExerciseTest.CheckSource.Compiler, as: CheckSourceCompiler
  alias ElixirAnalyzer.ExerciseTest.CommonChecks

  alias ElixirAnalyzer.Submission
  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Comment

  @doc false
  defmacro __using__(opts) do
    quote do
      use ElixirAnalyzer.ExerciseTest.Feature
      use ElixirAnalyzer.ExerciseTest.AssertCall
      use ElixirAnalyzer.ExerciseTest.CheckSource
      use ElixirAnalyzer.ExerciseTest.CommonChecks
      @suppress_tests unquote(opts)[:suppress_tests]

      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
      @dialyzer no_match: {:do_analyze, 4}
    end
  end

  #
  #  Compile @feature_tests into features function in the __before_compile__ macro
  #

  defmacro __before_compile__(env) do
    # credo:disable-for-previous-line Credo.Check.Refactor.CyclomaticComplexity
    feature_test_data = Module.get_attribute(env.module, :feature_tests)
    assert_call_data = Module.get_attribute(env.module, :assert_call_tests)
    check_source_data = Module.get_attribute(env.module, :check_source_tests)
    suppress_tests = Module.get_attribute(env.module, :suppress_tests, [])

    # placeholders for submission code
    code_ast = quote do: code_ast
    code_as_string = quote do: code_as_string

    # compile each feature to a test
    feature_tests = Enum.map(feature_test_data, &FeatureCompiler.compile(&1, code_ast))

    # compile each assert_call to a test
    assert_call_tests = Enum.map(assert_call_data, &AssertCallCompiler.compile(&1, code_ast))

    # compile each check_source to a test
    check_source_tests =
      Enum.map(check_source_data, &CheckSourceCompiler.compile(&1, code_as_string))

    quote do
      @spec analyze(Submission.t(), String.t(), nil | Macro.t()) :: Submission.t()
      def analyze(%Submission{} = submission, code_as_string, exemplar_ast) do
        case Code.string_to_quoted(code_as_string) do
          {:ok, code_ast} ->
            do_analyze(submission, code_ast, code_as_string, exemplar_ast)

          {:error, e} ->
            append_analysis_failure(submission, e)
        end
      end

      defp do_analyze(%Submission{} = submission, code_ast, code_as_string, exemplar_ast)
           when is_binary(code_as_string) do
        results =
          Enum.concat([
            unquote(feature_tests),
            unquote(assert_call_tests),
            unquote(check_source_tests),
            CommonChecks.run(code_ast, code_as_string, exemplar_ast)
          ])
          |> filter_suppressed_results()

        submission
        |> append_test_comments(results)
        |> Submission.sort_comments()
      end

      defp filter_suppressed_results(feature_results) do
        Enum.reject(feature_results, fn
          {_test_result, %{suppress_if: condition}} when condition !== false ->
            any_result_matches_suppress_condition?(feature_results, condition)

          {_test_result, %{comment: comment}} ->
            comment in unquote(suppress_tests)
        end)
      end

      defp any_result_matches_suppress_condition?(feature_results, condition) do
        {suppress_on_test_name, suppress_on_result} = condition

        Enum.any?(feature_results, fn {result, test} ->
          case {result, test.name} do
            {^suppress_on_result, ^suppress_on_test_name} -> true
            _ -> false
          end
        end)
      end

      defp append_test_comments(%Submission{} = submission, results) do
        Enum.reduce(results, submission, fn
          {:skip, _description}, submission ->
            submission

          {:pass, %Comment{} = comment}, submission ->
            if Map.get(comment, :type, false) == :celebratory do
              Submission.append_comment(submission, comment)
            else
              submission
            end

          {:fail, %Comment{} = comment}, submission ->
            if Map.get(comment, :type, false) != :celebratory do
              Submission.append_comment(submission, comment)
            else
              submission
            end

          _, s ->
            s
        end)
      end

      defp append_analysis_failure(%Submission{} = submission, {location, error, token}) do
        line = Keyword.get(location, :line)
        comment_params = %{line: line, error: "#{error}#{token}"}

        submission
        |> Submission.halt()
        |> Submission.append_comment(%Comment{
          comment: Constants.general_parsing_error(),
          params: comment_params,
          type: :essential
        })
      end
    end
  end
end
