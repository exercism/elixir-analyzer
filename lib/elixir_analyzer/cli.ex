defmodule ElixirAnalyzer.CLI do
  @usage """
  Usage:

    $ elixir_analyzer <exercise-name> <path> [options]

  You may also pass the following options:
    --skip-analysis                       flag skips running the static analysis
    --output <path>                       where to print the output, default to path
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
        strict: (for {o, _} <- @options, do: o)
      )

    case cmd_opts do
      {[help: true], _, _}           -> :help

      {[analyze_file: target], _, _} ->
        [fullpath, module] = String.split(target, ":", trim: true)
        path = Path.dirname(fullpath)
        file = Path.basename(fullpath)
        {Enum.into([module: module, file: file], options), "undefined", path}

      {opts, [exercise, path], _}    -> {Enum.into(opts, options), exercise, path}

      _                              -> :help
    end
  end

  def process(:help), do: IO.puts(@usage)

  def process({options, exercise, path}) do
    opts =
      @options
      |> Enum.reduce(options, fn {{o, _}, d}, acc ->
        Map.put_new(acc, o, d)
      end)
      |> Map.to_list()

    ElixirAnalyzer.analyze_exercise(exercise, path, opts)
  end
end
