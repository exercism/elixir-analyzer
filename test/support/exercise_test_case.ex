defmodule ElixirAnalyzer.ExerciseTestCase do
  @moduledoc """
    A test case for exercise test module tests.

    ## Usage

    ```
    use ElixirAnalyzer.ExerciseTestCase, exercise_test_module: ElixirAnalyzer.ExerciseTest.ExerciseName
    ```
  """

  use ExUnit.CaseTemplate

  @dialyzer no_match: {:assert_comments, 3}

  using opts do
    quote do
      @exercise_test_module unquote(opts)[:exercise_test_module]
      @unsorted_comments unquote(opts)[:unsorted_comments]
      require ElixirAnalyzer.ExerciseTestCase
      import ElixirAnalyzer.ExerciseTestCase
      alias ElixirAnalyzer.Constants
    end
  end

  @doc ~S"""
    Defines test cases for the exercise test module.

    ## Usage

    ```
    test_exercise_analysis "missing moduledoc",
      comments: [Constants.solution_use_moduledoc()] do
      defmodule TwoFer do
        @spec two_fer(String.t()) :: String.t()
        def two_fer(name \\ "you") when is_binary(name) do
          "One for #{name}, one for me."
        end
      end
    end
    ```

    ## Assertions

    All assertions are optional, but at least one is required.

    - `:comments` - checks that the comments produced by the analysis and this list have the same elements, ignoring their order.
    - `:comments_include` - checks that the comments produced by the analysis include all elements from this list.
    - `:comments_exclude` - checks that the comments produced by the analysis include none of the elements from this list.

    ## Code

    The code of solutions to be analyzed should be passed in the `do` block directly, without quoting.
    Passing a list of code blocks is also supported.
  """
  defmacro test_exercise_analysis(name, assertions, do: test_cases) do
    supported_assertions_keys = [:comments, :comments_include, :comments_exclude]
    assertions_keys = Keyword.keys(assertions)
    assertions_key_diff = assertions_keys -- supported_assertions_keys

    if assertions_keys == [] do
      raise "Expected to receive at least one of the supported assertions: #{Enum.join(supported_assertions_keys)}"
    end

    if assertions_key_diff != [] do
      raise "Unsupported assertion received: #{Enum.join(assertions_key_diff)}"
    end

    test_cases = List.wrap(test_cases)

    test_cases
    |> Enum.with_index()
    |> Enum.map(fn {code, index} ->
      test_name =
        case test_cases do
          [_, _ | _] -> "#{name} #{index + 1}"
          _ -> name
        end

      {line, code} =
        case code do
          {_, [line: line], _} -> {line, Macro.to_string(code)}
          _ -> {__CALLER__.line, code}
        end

      quote line: line do
        test "#{unquote(test_name)}" do
          empty_submission = %ElixirAnalyzer.Submission{
            code_file: "",
            code_path: "",
            path: "",
            analysis_module: ""
          }

          result = @exercise_test_module.analyze(empty_submission, unquote(code))

          comments =
            result.comments
            |> Enum.map(fn comment_details -> comment_details.comment end)

          Enum.map(Keyword.keys(unquote(assertions)), fn
            :comments ->
              assert_comments(comments, :comments, unquote(assertions),
                unsorted: @unsorted_comments
              )

            key ->
              assert_comments(comments, key, unquote(assertions))
          end)
        end
      end
    end)
  end

  def assert_comments(comments, :comments, assertions, unsorted: unsorted) do
    expected_comments = assertions[:comments]

    cond do
      expected_comments && unsorted ->
        assert comments == expected_comments

      expected_comments ->
        assert Enum.sort(comments) == Enum.sort(expected_comments)
    end
  end

  def assert_comments(comments, :comments_include, assertions) do
    comments_include = assertions[:comments_include]

    if comments_include do
      Enum.each(comments_include, fn comment ->
        assert comment in comments
      end)
    end
  end

  def assert_comments(comments, :comments_exclude, assertions) do
    comments_exclude = assertions[:comments_exclude]

    if comments_exclude do
      Enum.each(comments_exclude, fn comment ->
        refute comment in comments
      end)
    end
  end

  def assert_comments(_, _, _) do
    :noop
  end
end
