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
  @exercise_config Application.compile_env(:elixir_analyzer, :exercise_config)
  @concept_exercice_path "elixir/exercises/concept"
  @meta_config ".meta/config.json"

  using opts do
    quote do
      @exercise_test_module unquote(opts)[:exercise_test_module]
      @unsorted_comments unquote(opts)[:unsorted_comments]
      @exemplar_code ElixirAnalyzer.ExerciseTestCase.find_exemplar_code(@exercise_test_module)
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
    alias ElixirAnalyzer.Constants

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

          result = @exercise_test_module.analyze(empty_submission, unquote(code), @exemplar_code)

          comments =
            result.comments
            |> Enum.map(fn comment_details -> comment_details.comment end)
            # There are too many compiler warnings in tests
            |> Enum.reject(&(&1 == Constants.solution_compiler_warnings()))

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

  # Return the exemplar AST for concept exercises, or nil for pracices exercises and other tests
  def find_exemplar_code(test_module) do
    with {slug, _test_module} <-
           Enum.find(@exercise_config, &match?({_, %{analyzer_module: ^test_module}}, &1)),
         {:ok, config_file} <-
           Path.join([@concept_exercice_path, slug, @meta_config]) |> File.read() do
      get_exemplar_ast!(config_file, slug)
    else
      _ -> nil
    end
  end

  defp get_exemplar_ast!(config_file_path, slug) do
    %{"files" => %{"exemplar" => [path]}} = Jason.decode!(config_file_path)

    Path.join([@concept_exercice_path, slug, path])
    |> File.read!()
    |> Code.string_to_quoted!()
  end
end
