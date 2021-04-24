defmodule ElixirAnalyzer do
  @moduledoc """
  Static analysis framework for Elixir using a domain specific language and pattern
  matching.
  """

  require Logger

  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Submission

  import ElixirAnalyzer.Summary, only: [summary: 2]

  # defaults
  @exercise_config Application.compile_env(:elixir_analyzer, :exercise_config)
  @output_file "analysis.json"
  @meta_config ".meta/config.json"

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

  * `:exercise_config` - specifies the path to the JSON exercise configuration,
    defaults to `@exercise_config` (`./config/exercise_data.json`)

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
      {:file, nil},
      {:module, nil},
      {:output_path, output_path},
      {:output_file, @output_file},
      {:exercise_config, @exercise_config},
      {:write_results, true},
      {:puts_summary, true}
    ]

    Enum.reduce(defaults, Enum.into(opts, %{}), fn {k, v}, params -> Map.put_new(params, k, v) end)
  end

  # Do init work
  # -read config, create the initial Submission struct
  defp init(params) do
    submission = %Submission{
      path: params.path,
      code_path: nil,
      code_file: nil,
      analysis_module: nil
    }

    try do
      Logger.debug("Getting the exercise config")
      exercise_config = params.exercise_config[params.exercise]
      {code_path, code_file, analysis_module} = do_init(params, exercise_config)

      Logger.debug("Initialization successful",
        path: params.path,
        code_path: code_path,
        analysis_module: analysis_module
      )

      case Code.ensure_compiled(analysis_module) do
        {:error, reason} ->
          Logger.error("Loading exercise test suite '#{analysis_module}' failed (#{reason}).")
          raise ArgumentError

        {:module, m} ->
          Logger.info("Exercise test suite '#{m}' found and loaded.")
      end

      %{
        submission
        | code_path: code_path,
          code_file: code_file,
          analysis_module: analysis_module
      }
    rescue
      e in ArgumentError ->
        Logger.warning("TestSuite halted, ArgumentError", error_message: e.message)

        submission
        |> Submission.halt()
        |> Submission.set_halt_reason(
          "Analysis skipped, no analysis suite exists for this exercise"
        )

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
    end
  end

  # When file is nil, pull code params from config file
  defp do_init(%{file: nil} = params, exercise_config) do
    meta_config = Path.join(params.path, @meta_config) |> File.read!() |> Jason.decode!()
    relative_code_path = meta_config["files"]["solution"] |> hd()
    full_code_path = Path.join(params.path, relative_code_path)

    code_path = Path.dirname(full_code_path)
    code_file = Path.basename(full_code_path)

    {code_path, code_file, exercise_config.analyzer_module}
  end

  # Else, use passed in params to analyze
  defp do_init(params, _exercise_config) do
    {
      params.path,
      params.file,
      String.to_existing_atom("ElixirAnalyzer.ExerciseTest.#{params.module}")
    }
  end

  # Check
  # - check if the file exists
  # - read in the code
  # - compile
  defp check(%Submission{halted: true} = submission, _params) do
    Logger.warning("Check not performed, halted previously")
    submission
  end

  defp check(%Submission{} = submission, _params) do
    with path_to_code <- Path.join(submission.code_path, submission.code_file),
         :ok <- Logger.info("Attempting to read code file", code_file_path: path_to_code),
         {:code_read, {:ok, code_str}} <- {:code_read, File.read(path_to_code)},
         :ok <- Logger.info("Code file read successfully"),
         {:code_str, submission} <- {:code_str, %{submission | code: code_str}} do
      submission
    else
      {:code_read, {:error, reason}} ->
        Logger.warning("TestSuite halted: Code file not found. Reason: #{reason}",
          path: submission.path,
          file_name: submission.code_file
        )

        submission
        |> Submission.halt()
        |> Submission.append_comment(%{
          comment: Constants.general_file_not_found(),
          params: %{
            "file_name" => submission.code_file,
            "path" => submission.path
          },
          type: :essential
        })
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
      |> submission.analysis_module.analyze(submission.code)
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
