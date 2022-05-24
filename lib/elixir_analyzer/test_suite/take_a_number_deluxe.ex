defmodule ElixirAnalyzer.TestSuite.TakeANumberDeluxe do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise rpg-character-sheet
  """

  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Source

  use ElixirAnalyzer.ExerciseTest,
    # this is temporary until we include editor files in compilation
    suppress_tests: [Constants.solution_compiler_warnings()]

  feature "uses GenServer" do
    type :actionable
    find :any
    comment Constants.take_a_number_deluxe_use_genserver()

    form do
      use GenServer
    end
  end

  check_source "uses @impl GenServer" do
    type :actionable
    comment Constants.take_a_number_deluxe_annotate_impl_genserver()

    check(%Source{code_ast: code_ast}) do
      {_, %{defs_without_impls: defs_without_impls}} =
        Macro.postwalk(code_ast, %{defs_without_impls: [], impl?: false}, &find_defs_and_impls/2)

      defs_without_impls == []
    end
  end

  @def_ops [:def, :defp, :defmacro, :defmacrop, :defguard, :defguardp]
  @genserver_callbacks_in_this_exercise [:init, :handle_call, :handle_cast, :handle_info]
  defp find_defs_and_impls(node, acc) do
    acc =
      case node do
        {:@, _, [{:impl, _, [{:__aliases__, _, [:GenServer]}]}]} ->
          %{acc | impl?: true}

        {op, _, [{function_name, _, _} | _]} when op in @def_ops ->
          if function_name in @genserver_callbacks_in_this_exercise and !acc.impl? do
            %{acc | impl?: false, defs_without_impls: [function_name | acc.defs_without_impls]}
          else
            %{acc | impl?: false}
          end

        _ ->
          acc
      end

    {node, acc}
  end
end
