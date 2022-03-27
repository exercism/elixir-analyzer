defmodule ElixirAnalyzer.CLI do
  @moduledoc """
  A CLI for running analysis on a single solution.
  """

  @usage """
  Usage:

    $ elixir_analyzer <exercise-name> <input path> <output path> [options]

  You may also pass the following options:
    --help                          see this message
    --output-file <filename>        output file name (default: analysis.json)
    --no-write-results              doesn't write to JSON file
    --no-puts-summary               doesn't print summary to stdio
  """

  @options [
    {{:output_file, :string}, "analysis.json"},
    {{:write_results, :boolean}, true},
    {{:puts_summary, :boolean}, true},
    {{:help, :boolean}, false}
  ]

  @spec main(list(String.t())) :: no_return
  def main(args) do
    args |> parse_args() |> process()
  end

  defp parse_args(args) do
    default_ops = for({{key, _}, val} <- @options, do: {key, val}, into: %{})

    cmd_opts = OptionParser.parse(args, strict: for({o, _} <- @options, do: o))

    case cmd_opts do
      {[help: true], _, _} ->
        :help

      {opts, [exercise, input_path, output_path], _} ->
        {Enum.into(opts, default_ops), exercise, input_path, output_path}
    end
  rescue
    _ -> :help
  end

  defp process(:help), do: IO.puts(@usage)

  defp process({options, exercise, input_path, output_path}) do
    opts = Map.to_list(options)

    ElixirAnalyzer.analyze_exercise(exercise, input_path, output_path, opts)
  end
end
