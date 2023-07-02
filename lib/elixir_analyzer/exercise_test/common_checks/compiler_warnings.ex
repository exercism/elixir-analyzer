defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.CompilerWarnings do
  @moduledoc """
  This is an exercise analyzer extension module used for capturing compiler warnings
  """
  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Comment

  def run(code_path) do
    Logger.configure(level: :critical)

    warnings =
      case Kernel.ParallelCompiler.compile(code_path) do
        {:ok, modules, warnings} ->
          Enum.each(modules, fn module ->
            :code.delete(module)
            :code.purge(module)
          end)

          warnings

        {:error, _errors, _warnings} ->
          # This should not happen, as real code is assumed to have compiled and
          # passed the tests
          []
      end

    Logger.configure(level: :warning)

    Application.put_env(:elixir, :ansi_enabled, true)

    if Enum.empty?(warnings) do
      []
    else
      [
        {:fail,
         %Comment{
           type: :actionable,
           name: Constants.solution_compiler_warnings(),
           comment: Constants.solution_compiler_warnings(),
           params: %{warnings: Enum.map_join(warnings, &format_warning/1)}
         }}
      ]
    end
  end

  defp format_warning({filepath, line, warning}) do
    [_ | after_lib] = String.split(filepath, "/lib/")
    filepath = "lib/" <> Enum.join(after_lib)

    """
    warning: #{warning}
      #{filepath}:#{line}

    """
  end
end
