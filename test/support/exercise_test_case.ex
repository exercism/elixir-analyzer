defmodule ElixirAnalyzer.ExerciseTestCase do
  @moduledoc """
    A test case for exercise test module tests.

    ## Usage

    ```
    use ElixirAnalyzer.ExerciseTestCase, exercise_test_module: ElixirAnalyzer.ExerciseTest.ExerciseName
    ```
  """

  use ExUnit.CaseTemplate
  alias ElixirAnalyzer.Source

  @dialyzer no_match: {:assert_comments, 3}
  @exercise_config Application.compile_env(:elixir_analyzer, :exercise_config)

  using opts do
    quote do
      @exercise_test_module unquote(opts)[:exercise_test_module]
      @unsorted_comments unquote(opts)[:unsorted_comments]
      @source ElixirAnalyzer.ExerciseTestCase.find_source(@exercise_test_module)
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
      supported = Enum.join(supported_assertions_keys, ", ")
      raise "Expected to receive at least one of the supported assertions: #{supported}"
    end

    if assertions_key_diff != [] do
      raise "Unsupported assertions received: #{Enum.join(assertions_key_diff, ", ")}"
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
          source = %{@source | code_string: unquote(code)}

          empty_submission = %ElixirAnalyzer.Submission{
            source: source,
            analysis_module: ""
          }

          result = @exercise_test_module.analyze(empty_submission)

          comments =
            result.comments
            |> Enum.map(fn comment_details -> comment_details.comment end)
            |> Enum.reject(fn comment ->
              # Exclude common comment that's appended to all solutions that have negative comments
              # There are too many compiler warnings in tests
              comment =~ ~r[open an issue] or
                comment == Constants.solution_compiler_warnings()
            end)

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

  # Return as much of the source data as can be found

  @concept_exercise_path "elixir/exercises/concept"
  @practice_exercise_path "elixir/exercises/practice"
  @meta_config ".meta/config.json"
  def find_source(test_module) do
    %Source{}
    |> find_source_slug(test_module)
    |> find_source_type
    |> find_source_exemploid_path
    |> find_source_exemploid
  end

  defp find_source_slug(source, test_module) do
    match_slug = Enum.find(@exercise_config, &match?({_, %{analyzer_module: ^test_module}}, &1))

    case match_slug do
      {slug, _test_module} -> %{source | slug: slug}
      _ -> source
    end
  end

  defp find_source_type(%Source{slug: slug} = source) do
    concept_ex = File.ls!(@concept_exercise_path)
    practice_ex = File.ls!(@practice_exercise_path)

    cond do
      slug in concept_ex -> %{source | exercise_type: :concept}
      slug in practice_ex -> %{source | exercise_type: :practice}
      true -> source
    end
  end

  defp find_source_exemploid_path(%Source{slug: slug, exercise_type: :concept} = source) do
    %{"files" => %{"exemplar" => [exemploid_path | _]}} =
      [@concept_exercise_path, slug, @meta_config]
      |> Path.join()
      |> File.read!()
      |> Jason.decode!()

    exemploid_path = Path.join([@concept_exercise_path, slug, exemploid_path])
    %{source | exemploid_path: exemploid_path}
  end

  defp find_source_exemploid_path(%Source{slug: slug, exercise_type: :practice} = source) do
    %{"files" => %{"example" => [exemploid_path | _]}} =
      [@practice_exercise_path, slug, @meta_config]
      |> Path.join()
      |> File.read!()
      |> Jason.decode!()

    exemploid_path = Path.join([@practice_exercise_path, slug, exemploid_path])

    %{source | exemploid_path: exemploid_path}
  end

  defp find_source_exemploid_path(source), do: source

  defp find_source_exemploid(%Source{exemploid_path: exemploid_path} = source)
       when is_binary(exemploid_path) do
    exemploid_string = File.read!(exemploid_path)

    exemploid_ast =
      exemploid_string
      |> Code.format_string!(line_length: 120, force_do_end_blocks: true)
      |> IO.iodata_to_binary()
      |> Code.string_to_quoted!()

    %{source | exemploid_string: exemploid_string, exemploid_ast: exemploid_ast}
  end

  defp find_source_exemploid(source), do: source
end
