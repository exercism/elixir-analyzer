defmodule ElixirAnalyzer.TestSuite.DancingDots do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise rpg-character-sheet
  """

  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Source

  use ElixirAnalyzer.ExerciseTest

  feature "DancingDots.Flicker shouldn't reimplement init/1" do
    type :essential
    find :none
    comment Constants.dancing_dots_do_not_reimplement_init()

    form do
      defmodule DancingDots.Flicker do
        _block_includes do
          def init(_ignore), do: _ignore
        end
      end
    end
  end

  check_source "uses @impl DancingDots.Animation" do
    type :actionable
    comment Constants.dancing_dots_annotate_impl_animation()

    check(%Source{code_ast: code_ast}) do
      {_, %{aliases: aliases}} =
        Macro.prewalk(
          code_ast,
          %{aliases: []},
          &find_aliases/2
        )

      {_, %{defs_without_impls: defs_without_impls}} =
        Macro.prewalk(
          code_ast,
          %{defs_without_impls: [], impl?: false, skip?: false, aliases: aliases},
          &find_defs_and_impls/2
        )

      defs_without_impls == []
    end
  end

  @def_ops [:def, :defp, :defmacro, :defmacrop, :defguard, :defguardp]
  @callbacks_in_this_exercise [:init, :handle_frame]
  @behaviour_module [:DancingDots, :Animation]
  defp find_aliases(node, acc) do
    acc =
      case node do
        {:alias, _, [{:__aliases__, _, @behaviour_module}]} ->
          alias = [List.last(@behaviour_module)]
          %{acc | aliases: [alias | acc.aliases]}

        {:alias, _, [{:__aliases__, _, @behaviour_module}, [as: {:__aliases__, _, alias}]]} ->
          %{acc | aliases: [alias | acc.aliases]}

        _ ->
          acc
      end

    {node, acc}
  end

  defp find_defs_and_impls(node, acc) do
    acc =
      case node do
        {:defmodule, _, [{:__aliases__, _, module_name} | _]} ->
          %{acc | impl?: false, skip?: module_name == @behaviour_module}

        {:@, _, [{:impl, _, [{:__aliases__, _, module_name}]}]} ->
          %{
            acc
            | impl?: module_name in [@behaviour_module | acc.aliases]
          }

        {op, _, [{function_name, _, _} | _]} when op in @def_ops ->
          if function_name in @callbacks_in_this_exercise and !acc.impl? and !acc.skip? do
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
