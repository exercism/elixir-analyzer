defmodule ElixirAnalyzer.CLITest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  alias ElixirAnalyzer.CLI
  alias ElixirAnalyzer.{Source, Submission}

  @lasagna_path "test_data/lasagna/perfect_solution"
  @help """
  Usage:

    $ elixir_analyzer <exercise-name> <input path> <output path> [options]

  You may also pass the following options:
    --help                          see this message
    --output-file <filename>        output file name (default: analysis.json)
    --no-write-results              doesn't write to JSON file
    --no-puts-summary               doesn't print summary to stdio
  """

  defp match_submission(%Submission{
         analysis_module: ElixirAnalyzer.TestSuite.Lasagna,
         analyzed: true,
         comments: [
           %{comment: "elixir.solution.same_as_exemplar", type: :celebratory}
         ],
         halt_reason: nil,
         halted: false,
         source: %Source{
           code_ast: {:defmodule, _, _},
           code_string: "defmodule Lasagna" <> _,
           code_path: @lasagna_path <> "/lib/lasagna.ex",
           exemploid_ast: {:defmodule, _, _},
           exemploid_string: "defmodule Lasagna" <> _,
           exemploid_path: @lasagna_path <> "/.meta/exemplar.ex",
           exercise_type: :concept,
           path: @lasagna_path,
           slug: "lasagna"
         }
       }) do
    true
  end

  defp match_submission(_), do: false

  @lasagna_result "{\"comments\":[{\"comment\":\"elixir.solution.same_as_exemplar\",\"type\":\"celebratory\"}],\"summary\":\"You're doing something right. 🎉\"}"

  setup do
    on_exit(fn ->
      Enum.each(["analysis.json", "output.json"], &File.rm(Path.join(@lasagna_path, &1)))
    end)
  end

  test "getting help" do
    assert capture_io(fn -> CLI.main(["--help"]) end) =~ @help
  end

  test "incorrect arguments" do
    assert capture_io(fn -> CLI.main(["--hello"]) end) =~ @help
  end

  test "analyze a file with default values" do
    summary = """
    ElixirAnalyzer Report
    ---------------------

    Exercise: lasagna
    Status: Analysis Complete
    Output written to ... test_data/lasagna/perfect_solution/analysis.json
    """

    assert capture_io(fn ->
             assert CLI.main(["lasagna", @lasagna_path, @lasagna_path]) |> match_submission
           end) =~ summary

    assert File.read!(Path.join(@lasagna_path, "analysis.json")) == @lasagna_result
  end

  test "analyze a file with different output path" do
    summary = """
    ElixirAnalyzer Report
    ---------------------

    Exercise: lasagna
    Status: Analysis Complete
    Output written to ... test_data/lasagna/perfect_solution/output.json
    """

    assert capture_io(fn ->
             assert CLI.main([
                      "lasagna",
                      @lasagna_path,
                      @lasagna_path,
                      "--output-file",
                      "output.json"
                    ])
                    |> match_submission
           end) =~ summary

    assert File.read!(Path.join(@lasagna_path, "output.json")) == @lasagna_result
  end

  test "analyze a file, no output" do
    assert capture_io(fn ->
             assert CLI.main([
                      "lasagna",
                      @lasagna_path,
                      @lasagna_path,
                      "--no-write-results",
                      "--no-puts-summary"
                    ])
                    |> match_submission
           end) == ""

    assert {:error, :enoent} = File.read(Path.join(@lasagna_path, "analysis.json"))
  end
end
