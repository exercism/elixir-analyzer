defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.CompilerWarnings do
  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Comment

  def run(code_ast) do
    import ExUnit.CaptureIO

    warnings =
      capture_io(:stderr, fn ->
        try do
          Code.compile_quoted(code_ast)
          |> Enum.each(fn {module, _binary} ->
            :code.delete(module)
            :code.purge(module)
          end)
        rescue
          # There are too many compile errors for tests, so we filter them out
          # We assume that real code passed the tests and therefore compiles
          _ -> nil
        end
      end)

    if warnings == "" do
      []
    else
      [
        {:fail,
         %Comment{
           type: :actionable,
           name: Constants.solution_compiler_warnings(),
           comment: Constants.solution_compiler_warnings(),
           params: %{warnings: warnings}
         }}
      ]
    end
  end
end
