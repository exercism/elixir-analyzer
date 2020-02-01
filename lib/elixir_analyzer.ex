defmodule ElixirAnalyzer do
  @moduledoc """
  Static analysis framework for Elixir using a domain specifc language and pattern
  matching.
  """

  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Submission

  import ElixirAnalyzer.Summary, only: [summary: 2]

  # defaults
  @exercise_config "./config/exercise_data.json"
  @output_file "analyze.json"
  @lib_dir "lib"

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

  * `:output_file`, - specificies the name of the output_file, defaults to
    `@output_file` (`analyze.json`)

  * `:exercise_config` - specifies the path to the JSON exercise configuration,
    defaults to `@exercise_config` (`./config/exercise_data.json`)

  * `:write_results` - boolean flag if an ananlysis should output the results to
    JSON file, defaults to `true`

  * `:puts_summary` - boolean flag if an ananlysis should print the summary of the
    analysis to stdio, defaults to `true`

  Any arbitrary keyword-value pair can be passed to `analyze_exercise/3` and these options may be used the other consuming code.
  """
  @spec analyze_exercise(String.t(), String.t(), keyword()) :: Submission.t()
  def analyze_exercise(exercise, path, opts \\ []) do
    params = get_params(exercise, path, opts)

    s =
      init(params)
      |> check(params)
      |> analyze(params)
      |> Submission.finalize()
      |> write_results(params)

    if params.puts_summary do
      summary(s, params) |> IO.puts()
    end

    s
  end

  # translate arguments to a param map, adding in defaults
  @spec get_params(String.t(), String.t(), Keyword.t()) :: map()
  defp get_params(exercise, path, opts) do
    defaults = [
      {:exercise, exercise},
      {:path, path},
      {:file, nil},
      {:module, nil},
      {:output_path, path},
      {:output_file, @output_file},
      {:exercise_config, @exercise_config},
      {:write_results, true},
      {:puts_summary, true},
    ]

    Enum.reduce(defaults, Enum.into(opts, %{}), fn {k, v}, params -> Map.put_new(params, k, v) end)
  end

  # Do init work
  # -read config, create the inital Submission struch
  defp init(params) do
    {:ok, config_contents} = File.read(params.exercise_config)
    {:ok, config} = Jason.decode(config_contents)
    exercise_config = config[params.exercise]

    code_path = unless params.file, do: "#{params.path}/#{@lib_dir}", else: params.path
    code_file = unless params.file, do: exercise_config["code_file"], else: params.file
    analysis_module = unless params.file, do: exercise_config["analyzer_module"], else: "ElixirAnalyzer.ExerciseTest.#{params.module}"

    %Submission{
      path: params.path,
      code_path: code_path,
      code_file: code_file,
      analysis_module: String.to_existing_atom("Elixir.#{analysis_module}")
    }
  end

  # Check
  # - check if the file exists
  # - read in the code
  # - compile
  defp check(s = %Submission{}, _params) do
    with path_to_code <- "#{s.code_path}/#{s.code_file}",
         {:code_read, {:ok, code_str}} <- {:code_read, File.read(path_to_code)},
         {:code_str, s} <- {:code_str, %{s | code: code_str}} do
      s
    else
      {:code_read, {:error, _}} ->
        s
        |> Submission.halt()
        |> Submission.disapprove()
        |> Submission.append_comment({
          Constants.general_file_not_found,
          %{
            "file_name" => s.code_file,
            "path" => s.path
          }
        })
    end
  end

  # Analyze
  # - Start the static analysis
  defp analyze(s = %Submission{}, _params) do
    cond do
      s.halted ->
        s
        |> Submission.refer()

      true ->
        Kernel.apply(s.analysis_module, :analyze, [s, s.code])
        |> Submission.set_analyzed(true)
    end
  end

  defp write_results(s = %Submission{}, params) do
    if params.write_results do
      :ok = File.write("#{params.output_path}/#{params.output_file}", Submission.to_json(s))
    end

    s
  end
end
