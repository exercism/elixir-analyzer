defmodule ElixirAnalyzer.CLI do
  @usage """
  $ exmentor {--exercise exercise-name|exercise-name} {--path path-to|path-to}

  You may also pass the following optional flags:
    --skip-analysis           flag skips running the static analysis
    --output path, -o path    where to print the output, default to path
    --output-file filename, -f filename
  """

  @options [
    {{:skip_analyze, :boolean}, false},
    {{:exercise, :string}, nil},
    {{:path, :string}, nil},
    {{:output, :string}, nil},
    {{:output_file, :string}, "analyze.json"}
  ]

  @spec main() :: no_return
  @spec main(list(String.t())) :: no_return
  def main(args \\ []) do
    {options, argv, _} =
      OptionParser.parse(args,
        alias: [
          o: :output,
          f: :output_file
        ],
        strict: for({option, _default} <- @options, do: option)
      )

    exercise = Keyword.get(options, :exercise, false)
    path = Keyword.get(options, :path, false)

    {exercise, path, err} =
      case {exercise, path, argv} do
        {false, false, argv} when length(argv) >= 2 ->
          {Enum.at(argv, 0), Enum.at(argv, 1), false}

        {_, false, argv} when length(argv) >= 1 ->
          {exercise, Enum.at(argv, 0), false}

        {false, _, argv} when length(argv) >= 1 ->
          {Enum.at(argv, 0), path, false}

        _ ->
          {nil, nil, true}
      end

    if err do
      IO.puts(@usage)
    else
      opts =
        for {{option, _type}, default} <- @options,
            value = Keyword.get(options, option, default),
            value != nil,
            do: {option, value}

      ElixirAnalyzer.analyze_exercise(exercise, path, opts)
    end
  end
end
