defmodule ElixirAnalyzer do
  @moduledoc """
  Documentation for ElixirAnalyzer.
  """

  alias ElixirAnalyzer.Submission

  # defaults
  @exercise_config "./config/exercise_data.json"
  @output_file "analyze.json"
  @lib_dir "lib/"

  # Entrypoint
  @spec analyze_exercise(String.t(), String.t(), keyword()) :: Submission.t()
  def analyze_exercise(exercise, path, opts \\ []) do
    params = get_params(exercise, path, opts)

    s =
      init(params)
      |> check(params)
      |> analyze(params)
      |> Submission.finalize()
      |> write_results(params)

    summary = """
    #{exercise} analysis ... #{str_section_result(:halted, s, params)}!

    Analysis ... #{str_section_result(:analyzed, s, params)}
    Output written to ... \"#{path}#{params.output_file}\"
    """

    IO.puts(summary)

    s
  end

  # translate arguments to a param map
  def get_params(exercise, path, opts \\ []) do
    defaults = [
      {:exercise, exercise},
      {:path, path},
      {:output_path, path},
      {:output_file, @output_file},
      {:exercise_config, @exercise_config}
    ]

    Enum.reduce(defaults, Enum.into(opts, %{}), fn {k, v}, p -> Map.put_new(p, k, v) end)
  end

  # Do init work
  # -read config, create the inital Submission struch
  defp init(params) do
    config_contents = File.read!(params.exercise_config)
    config = Jason.decode!(config_contents)
    exercise_config = config[params.exercise]

    %Submission{
      path: params.path,
      code_path: params.path <> @lib_dir,
      code_file: exercise_config["code_file"],
      analysis_module: String.to_existing_atom("Elixir.#{exercise_config["analyzer_module"]}")
    }
  end

  # Check
  # - check if the file exists
  # - read in the code
  # - compile
  defp check(s = %Submission{}, _params) do
    with path_to_code <- "#{s.code_path}#{s.code_file}",
         {:code_read, {:ok, code_str}} <- {:code_read, File.read(path_to_code)},
         {:code_str, s} <- {:code_str, %{s | code: code_str}} do
      s
    else
      {:code_read, {:error, _}} ->
        s
        |> Submission.halt()
        |> Submission.disapprove()
        |> Submission.append_comment({
          "elixir.general.code_file_not_found",
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
    File.write!("#{params.output_path}#{params.output_file}", Submission.to_json(s))

    s
  end

  def str_section_result(key, s = %Submission{}, params) do
    case key do
      :halted ->
        cond do
          s.halted -> "Halted"
          true -> "Completed"
        end

      :compiled ->
        cond do
          params.skip_compile -> "Skipped"
          s.compiled -> "Compilation Complete"
          true -> "Compilation Error"
        end

      :tested ->
        cond do
          params.skip_test -> "Skipped"
          s.tested -> "Test Complete"
          true -> "Test Error"
        end

      :analyzed ->
        cond do
          s.analyzed -> "Analysis Complete"
          true -> "Analysis Error"
        end
    end
  end
end
