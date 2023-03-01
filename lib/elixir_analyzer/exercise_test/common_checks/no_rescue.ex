defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.NoRescue do
  @moduledoc """
  This is an exercise analyzer extension module used for common tests looking for the usage of `rescue`
  """

  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Source

  defmacro __using__(_opts) do
    quote do
      check_source Constants.solution_no_rescue() do
        type :essential
        comment Constants.solution_no_rescue()

        check(%Source{code_ast: code_ast}) do
          {_, found} =
            Macro.prewalk(code_ast, false, fn node, found ->
              case node do
                {def_op, _, [_function, [{:do, _} | rest]]} when def_op in [:def, :defp] ->
                  {node, found or List.keymember?(rest, :rescue, 0)}

                {:try, _, [[{:do, _} | rest]]} ->
                  {node, found or List.keymember?(rest, :rescue, 0)}

                _ ->
                  {node, found}
              end
            end)

          not found
        end
      end
    end
  end
end
