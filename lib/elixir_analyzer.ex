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

  * `input_path` is the path to the submitted solution

  * `output_path` is the path to the output folder

  * `opts` is a Keyword List of options, see **options**

  ## Options

  * `:output_file`, - specifies the name of the output_file, defaults to
    `@output_file` (`analysis.json`)

  * `:exercise_config` - specifies the path to the exercise configuration,
    defaults to `@exercise_config` (`./config/config.exs`)

  * `:write_results` - boolean flag if an analysis should output the results to
    JSON file, defaults to `true`

  * `:puts_summary` - boolean flag if an analysis should print the summary of the
    analysis to stdio, defaults to `true`
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
      {:path, String.trim_leading(input_path, "./")},
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

      {submitted_files, exercise_type, exemploid_files, analysis_module} =
        do_init(params, exercise_config)

      Logger.debug("Initialization successful",
        path: params.path,
        submitted_files: submitted_files,
        exercise_type: exercise_type,
        exemploid_files: exemploid_files,
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
        | submitted_files: submitted_files,
          exercise_type: exercise_type,
          exemploid_files: exemploid_files
      }

      %{
        submission
        | source: source,
          analysis_module: analysis_module
      }
    rescue
      e in File.Error ->
        Logger.warning("Unable to read config file #{e.path}", error_message: e.reason)

        submission
        |> Submission.halt()
        |> Submission.set_halt_reason("Analysis skipped, not able to read solution config.")

      e in Jason.DecodeError ->
        Logger.warning("Unable to decode 'config.json'", data: e.data)

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
    solution_files = meta_config["files"]["solution"] |> Enum.map(&Path.join(params.path, &1))
    if Enum.empty?(solution_files), do: raise("No solution files specified")

    submitted_files =
      Path.join([params.path, "lib", "**", "*.ex"])
      |> Path.wildcard()
      |> Enum.concat(solution_files)
      |> Enum.uniq()
      |> Enum.sort()

    editor_files = Map.get(meta_config["files"], "editor", [])

    {exercise_type, exemploid_files} =
      case meta_config["files"] do
        %{"exemplar" => path} -> {:concept, path}
        %{"example" => path} -> {:practice, path}
      end

    exemploid_files =
      (editor_files ++ exemploid_files) |> Enum.sort() |> Enum.map(&Path.join(params.path, &1))

    {submitted_files, exercise_type, exemploid_files,
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
    Logger.info("Attempting to read code files", code_file_path: source.submitted_files)

    with {:code_read, {:ok, code_string}} <- {:code_read, read_files(source.submitted_files)},
         source <- %{source | code_string: code_string},
         Logger.info("Code files read successfully"),
         Logger.info("Attempting to read exemploid", exemploid_files: source.exemploid_files),
         {:exemploid_read, _, {:ok, exemploid_string}} <-
           {:exemploid_read, source, read_files(source.exemploid_files)},
         Logger.info("Exemploid files read successfully, attempting to parse"),
         {:exemploid_ast, _, {:ok, exemploid_ast}} <-
           {:exemploid_ast, source, Code.string_to_quoted(exemploid_string)} do
      Logger.info("Exemploid file parsed successfully")
      source = %{source | exemploid_string: exemploid_string, exemploid_ast: exemploid_ast}
      %{submission | source: source}
    else
      {:code_read, {:error, reason}} ->
        Logger.warning("TestSuite halted: Code file not found. Reason: #{reason}",
          path: source.path,
          submitted_files: source.submitted_files
        )

        submission
        |> Submission.halt()
        |> Submission.append_comment(%Comment{
          comment: Constants.general_file_not_found(),
          params: %{
            "file_name" => Path.basename(source.submitted_files),
            "path" => source.path
          },
          type: :essential
        })

      {:exemploid_read, source, {:error, reason}} ->
        Logger.warning("Exemploid file not found. Reason: #{reason}",
          exemploid_files: source.exemploid_files
        )

        %{submission | source: source}

      {:exemploid_ast, source, {:error, reason}} ->
        Logger.warning("Exemploid file could not be parsed. Reason: #{inspect(reason)}",
          exemploid_files: source.exemploid_files
        )

        %{submission | source: source}
    end
  end

  defp read_files(paths) do
    Enum.reduce_while(
      paths,
      {:ok, nil},
      fn path, {:ok, code} ->
        case File.read(path) do
          {:ok, file} when is_nil(code) -> {:cont, {:ok, file}}
          {:ok, file} -> {:cont, {:ok, code <> "\n" <> file}}
          {:error, err} -> {:halt, {:error, err}}
        end
      end
    )
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
      |> submission.analysis_module.analyze()
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
