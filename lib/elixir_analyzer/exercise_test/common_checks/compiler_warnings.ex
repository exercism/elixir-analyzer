defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.CompilerWarnings do
  @moduledoc """
  This is an exercise analyzer extension module used for capturing compiler warnings
  """
  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Comment

  def run(code_path, code_ast) do
    import ExUnit.CaptureIO
    Application.put_env(:elixir, :ansi_enabled, false)

    warnings =
      capture_io(:stderr, fn ->
        try do
          :elixir_compiler.quoted(code_ast, code_path, fn _, _ -> :ok end)
          |> Enum.each(fn {module, map, binary} ->
            Module.ParallelChecker.verify([{map, binary}], [])

            :code.delete(module)
            :code.purge(module)
          end)
        rescue
          # There are too many compile errors for tests, so we filter them out
          # We assume that real code passed the tests and therefore compiles
          _ -> nil
        end
      end)

    Application.put_env(:elixir, :ansi_enabled, true)

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
