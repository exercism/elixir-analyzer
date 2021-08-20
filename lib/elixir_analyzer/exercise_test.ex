defmodule ElixirAnalyzer.ExerciseTest do
  @moduledoc false

  alias ElixirAnalyzer.ExerciseTest.Feature.Compiler, as: FeatureCompiler
  alias ElixirAnalyzer.ExerciseTest.AssertCall.Compiler, as: AssertCallCompiler
  alias ElixirAnalyzer.ExerciseTest.CommonChecks

  alias ElixirAnalyzer.Submission
  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Comment

  @doc false
  defmacro __using__(_opts) do
    quote do
      use ElixirAnalyzer.ExerciseTest.Feature
      use ElixirAnalyzer.ExerciseTest.AssertCall

      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
      @dialyzer no_match: {:do_analyze, 3}
    end
  end

  #
  #  Compile @feature_tests into features function in the __before_compile__ macro
  #

  defmacro __before_compile__(env) do
    # credo:disable-for-previous-line Credo.Check.Refactor.CyclomaticComplexity
    feature_test_data = Module.get_attribute(env.module, :feature_tests)
    assert_call_data = Module.get_attribute(env.module, :assert_call_tests)

    # ast placeholder for the submission code ast
    code_ast = quote do: code_ast

    # compile each feature to a test
    feature_tests = Enum.map(feature_test_data, &FeatureCompiler.compile(&1, code_ast))

    # compile each assert_call to a test
    assert_call_tests = Enum.map(assert_call_data, &AssertCallCompiler.compile(&1, code_ast))

    quote do
      @spec analyze(Submission.t(), String.t()) :: Submission.t()
      def analyze(%Submission{} = submission, code_as_string) when is_binary(code_as_string) do
        case Code.string_to_quoted(code_as_string) do
          {:ok, code_ast} ->
            do_analyze(submission, code_ast, code_as_string)

          {:error, e} ->
            append_analysis_failure(submission, e)
        end
      end

      defp do_analyze(%Submission{} = submission, code_ast, code_as_string)
           when is_binary(code_as_string) do
        feature_results = unquote(feature_tests) |> filter_suppressed_results()
        assert_call_results = unquote(assert_call_tests) |> filter_suppressed_results()
        common_checks_results = CommonChecks.run(code_ast, code_as_string)

        submission
        |> append_test_comments(feature_results)
        |> append_test_comments(assert_call_results)
        |> append_test_comments(common_checks_results)
        |> Submission.sort_comments()
      end

      defp filter_suppressed_results(feature_results) do
        feature_results
        |> Enum.reject(fn
          {_test_result, %{suppress_if: condition}} when condition !== false ->
            any_result_matches_suppress_condition?(feature_results, condition)

          _result ->
            false
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
