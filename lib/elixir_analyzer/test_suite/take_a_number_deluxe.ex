defmodule ElixirAnalyzer.TestSuite.TakeANumberDeluxe do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise rpg-character-sheet
  """

  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Source

  use ElixirAnalyzer.ExerciseTest

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
        Macro.prewalk(
          code_ast,
          %{defs_without_impls: [], impl?: false, defs_with_impls: []},
          &find_defs_and_impls/2
        )

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

        {:@, _, [{:impl, _, [true]}]} ->
          %{acc | impl?: true}

        {op, _, [{function_name, _, _} | _]} when op in @def_ops ->
          acc =
            cond do
              function_name in @genserver_callbacks_in_this_exercise and
                function_name not in acc.defs_with_impls and !acc.impl? ->
                %{acc | defs_without_impls: [function_name | acc.defs_without_impls]}

              acc.impl? ->
                %{acc | defs_with_impls: [function_name | acc.defs_with_impls]}

              true ->
                acc
            end

          %{acc | impl?: false}

        _ ->
          acc
      end

    {node, acc}
  end
end
