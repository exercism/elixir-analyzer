defmodule ElixirAnalyzer.CLI do
  @usage """
  Usage:

    $ elixir_analyzer <exercise-name> <input path> <output path>  [options]

  You may also pass the following options:
    --skip-analysis                       flag skips running the static analysis
    --output-file <filename>

  You may also test only individual files :
    (assuming analyzer tests are compiled for the named module)

    $ exercism_analyzer --analyze-file <full-path-to-.ex>:<module-name>
  """

  @options [
    {{:skip_analyze, :boolean}, false},
    {{:output_dir, :string}, nil},
    {{:output_file, :string}, "analyze.json"},
    {{:analyze_file, :string}, nil},
    {{:help, :boolean}, false}
  ]

  @spec main(list(String.t())) :: no_return
  def main(args) do
    args |> parse_args() |> process()
  end

  def parse_args(args) do
    options = %{
      :output_file => "analyze.json"
    }

    cmd_opts =
      OptionParser.parse(args,
        strict: for({o, _} <- @options, do: o)
      )

    case cmd_opts do
      {[help: true], _, _} ->
        :help

      {[analyze_file: target], _, _} ->
        [full_path, module] = String.split(target, ":", trim: true)
        path = Path.dirname(full_path)
        file = Path.basename(full_path)
        {Enum.into([module: module, file: file], options), "undefined", path}

      {opts, [exercise, input_path, output_path], _} ->
        {Enum.into(opts, options), exercise, input_path, output_path}
    end
  rescue
    _ -> :help
  end

  def process(:help), do: IO.puts(@usage)

  def process({options, exercise, input_path, output_path}) do
    opts = get_default_options(options)
    ElixirAnalyzer.analyze_exercise(exercise, input_path, output_path, opts)
  end

  defp get_default_options(options) do
    @options
    |> Enum.reduce(options, fn {{option, _}, default}, acc ->
      Map.put_new(acc, option, default)
    end)
    |> Map.to_list()
  end
end
