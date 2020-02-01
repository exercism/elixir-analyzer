defmodule ElixirAnalyzer.CLI do
  @usage """
  $ elixir_analyzer <exercise-name> <path> [options]

  You may also pass the following optional flags:
    --skip-analysis           flag skips running the static analysis
    --output path, -o path    where to print the output, default to path
    --output-file filename, -f filename
  """

  @options [
    {{:skip_analyze, :boolean}, false},
    {{:output_dir, :string}, nil},
    {{:output_file, :string}, "analyze.json"},
    {{:single_file, :boolean}, false},
    {{:help, :boolean}, false}
  ]

  @spec main(list(String.t())) :: no_return
  def main(args) do
    args |> parse_args() |> process()
  end

  def parse_args(args) when length(args) < 2, do: :help

  def parse_args(args) do
    options = %{
      :output_file => "analyze.json"
    }

    cmd_opts =
      OptionParser.parse(args,
        strict: (for {o, _} <- @options, do: o)
      )

    case cmd_opts do
      {[help: true], _, _}        -> :help
      {opts, [exercise, path], _} -> {Enum.into(opts, options), exercise, path}
      _                           -> :help
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
