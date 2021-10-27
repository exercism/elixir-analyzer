defmodule ElixirAnalyzer do
  @moduledoc """
  Static analysis framework for Elixir using a domain specific language and pattern
  matching.
  """

  require Logger

  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Submission
  alias ElixirAnalyzer.Comment
  alias ElixirAnalyzer.Source

  import ElixirAnalyzer.Summary, only: [summary: 2]

  # defaults
  @exercise_config Application.compile_env(:elixir_analyzer, :exercise_config)
  @output_file "analysis.json"
  @meta_config ".meta/config.json"

  def default_exercise_config() do
    @exercise_config
  end

  @doc """
  This is the main entry point to the analyzer.

  ## Parameters

  * `exercise` is which exercise is submitted to determine proper analysis

  * `path` is the path (ending with a '/') to the submitted solution

  * `opts` is a Keyword List of options, see **options**

  ## Options

  * `:exercise` - name of the exercise, defaults to the `exercise` parameter

  * `:path` - path to the submitted solution, defaults to the `path` parameter

  * `:output_path` - path to write file output, defaults to the `path` parameter

  * `:output_file`, - specifies the name of the output_file, defaults to
    `@output_file` (`analysis.json`)

  * `:exercise_config` - specifies the path to the exercise configuration,
    defaults to `@exercise_config` (`./config/config.exs`)

  * `:write_results` - boolean flag if an analysis should output the results to
    JSON file, defaults to `true`

  * `:puts_summary` - boolean flag if an analysis should print the summary of the
    analysis to stdio, defaults to `true`

  Any arbitrary keyword-value pair can be passed to `analyze_exercise/3` and these options may be used the other consuming code.
  """
  @spec analyze_exercise(String.t(), String.t(), String.t(), keyword()) :: Submission.t()
  def analyze_exercise(exercise, input_path, output_path, opts \\ []) do
    Logger.info("Analyzing #{exercise}")

    Logger.debug("Input: #{input_path}, Output: #{output_path}")

    params = get_params(exercise, input_path, output_path, opts)

    submission =
      init(params)
      |> check(params)
      |> analyze(params)
      |> write_results(params)

    if params.puts_summary do
      summary(submission, params) |> IO.puts()
    end

    Logger.info("analyze_exercise/4 done")

    submission
  end

  # translate arguments to a param map, adding in defaults
  @spec get_params(String.t(), String.t(), String.t(), Keyword.t()) :: map()
  defp get_params(exercise, input_path, output_path, opts) do
    Logger.debug("Getting initial params")

    defaults = [
      {:exercise, exercise},
      {:path, input_path},
      {:output_path, output_path},
      {:output_file, @output_file},
      {:exercise_config, default_exercise_config()},
      {:write_results, true},
      {:puts_summary, true}
    ]

    Enum.reduce(defaults, Enum.into(opts, %{}), fn {k, v}, params -> Map.put_new(params, k, v) end)
  end

  # Do init work
  # -read config, create the initial Submission struct
  defp init(params) do
    source = %Source{
      path: params.path,
      slug: params.exercise
    }

    submission = %Submission{
      source: source,
      analysis_module: nil
    }

    try do
      Logger.debug("Getting the exercise config")
      exercise_config = params.exercise_config[params.exercise]

      {code_path, exercise_type, exemploid_path, analysis_module} =
        do_init(params, exercise_config)

      Logger.debug("Initialization successful",
        path: params.path,
        code_path: code_path,
        exercise_type: exercise_type,
        exemploid_path: exemploid_path,
        analysis_module: analysis_module
      )

      case Code.ensure_compiled(analysis_module) do
        {:error, reason} ->
          Logger.error("Loading exercise test suite '#{analysis_module}' failed (#{reason}).")
          raise ArgumentError

        {:module, m} ->
          Logger.info("Exercise test suite '#{m}' found and loaded.")
      end

      source = %{
        source
        | code_path: code_path,
          exercise_type: exercise_type,
          exemploid_path: exemploid_path
      }

      %{
        submission
        | source: source,
          analysis_module: analysis_module
      }
    rescue
      e in File.Error ->
        Logger.warning("Unable to decode 'config.json'", error_message: e.message)

        submission
        |> Submission.halt()
        |> Submission.set_halt_reason("Analysis skipped, not able to read solution config.")

      e in Jason.DecodeError ->
        Logger.warning("Unable to decode 'config.json'", error_message: e.message)

        submission
        |> Submission.halt()
        |> Submission.set_halt_reason("Analysis skipped, not able to decode solution config.")

      e ->
        Logger.warning("TestSuite halted, #{e.__struct__}", error_message: e.message)

        submission
        |> Submission.halt()
        |> Submission.set_halt_reason("Analysis skipped, unexpected error #{e.__struct__}")
    end
  end

  defp do_init(params, exercise_config) do
    meta_config = Path.join(params.path, @meta_config) |> File.read!() |> Jason.decode!()
    relative_code_path = meta_config["files"]["solution"] |> hd()
    code_path = Path.join(params.path, relative_code_path)

    {exercise_type, exemploid_path} =
      case meta_config["files"] do
        %{"exemplar" => [path | _]} -> {:concept, Path.join(params.path, path)}
        %{"example" => [path | _]} -> {:practice, Path.join(params.path, path)}
      end

    {code_path, exercise_type, exemploid_path,
     exercise_config[:analyzer_module] || ElixirAnalyzer.TestSuite.Default}
  end

  # Check
  # - check if the file exists
  # - read in the code
  # - check if there is an exemploid
  # - read in the exemploid
  # - parse the exemploid into an AST
  defp check(%Submission{halted: true} = submission, _params) do
    Logger.warning("Check not performed, halted previously")
    submission
  end

  defp check(%Submission{source: source} = submission, _params) do
    Logger.info("Attempting to read code file", code_file_path: source.code_path)

    with {:code_read, {:ok, code_string}} <- {:code_read, File.read(source.code_path)},
         source <- %{source | code_string: code_string},
         Logger.info("Code file read successfully"),
         Logger.info("Attempting to read exemploid", exemploid_path: source.exemploid_path),
         {:exemploid_read, _, {:ok, exemploid_string}} <-
           {:exemploid_read, source, File.read(source.exemploid_path)},
         Logger.info("Exemploid file read successfully, attempting to parse"),
         {:exemploid_ast, _, {:ok, exemploid_ast}} <-
           {:exemploid_ast, source, Code.string_to_quoted(exemploid_string)} do
      Logger.info("Exemploid file parsed successfully")
      source = %{source | exemploid_string: exemploid_string, exemploid_ast: exemploid_ast}
      %{submission | source: source}
    else
      {:code_read, {:error, reason}} ->
        Logger.warning("TestSuite halted: Code file not found. Reason: #{reason}",
          path: source.path,
          code_path: source.code_path
        )

        submission
        |> Submission.halt()
        |> Submission.append_comment(%Comment{
          comment: Constants.general_file_not_found(),
          params: %{
            "file_name" => Path.basename(source.code_path),
            "path" => source.path
          },
          type: :essential
        })

      {:exemploid_read, source, {:error, reason}} ->
        Logger.warning("Exemploid file not found. Reason: #{reason}",
          exemploid_path: source.exemploid_path
        )

        %{submission | source: source}

      {:exemploid_ast, source, {:error, reason}} ->
        Logger.warning("Exemploid file could not be parsed. Reason: #{inspect(reason)}",
          exemploid_path: source.exemploid_path
        )

        %{submission | source: source}
    end
  end

  # Analyze
  # - Start the static analysis
  defp analyze(%Submission{halted: true} = submission, _params) do
    Logger.info("Analysis not performed, halted previously")
    submission
  end

  defp analyze(%Submission{} = submission, _params) do
    Logger.info("Analyzing code started")

    submission =
      submission
      |> submission.analysis_module.analyze(submission.source)
      |> Submission.set_analyzed(true)

    Logger.info("Analyzing code complete")
    submission
  end

  defp write_results(%Submission{} = submission, params) do
    if params.write_results do
      output_file_path = Path.join(params.output_path, params.output_file)
      Logger.info("Writing final results.json to file", path: output_file_path)
      :ok = File.write(output_file_path, Submission.to_json(submission))
    else
      Logger.info("Final results not written to file")
    end

    submission
  end
end
