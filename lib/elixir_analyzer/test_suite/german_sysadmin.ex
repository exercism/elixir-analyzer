defmodule ElixirAnalyzer.TestSuite.GermanSysadmin do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise German Sysadmin
  """

  use ElixirAnalyzer.ExerciseTest
  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Source

  assert_no_call "doesn't convert anything to a string" do
    type :essential
    called_fn name: :to_string
    comment Constants.german_sysadmin_no_string()
  end

  assert_no_call "doesn't convert anything to a charlist" do
    type :essential
    called_fn name: :to_charlist
    comment Constants.german_sysadmin_no_string()
  end

  assert_no_call "doesn't use any string functions" do
    type :essential
    called_fn module: String, name: :_
    comment Constants.german_sysadmin_no_string()
  end

  assert_call "using case is required" do
    type :essential
    called_fn name: :case
    comment Constants.german_sysadmin_use_case()
  end

  check_source "does not use integer literals for code points" do
    type :actionable
    comment Constants.solution_no_integer_literal()

    check(%Source{code_string: code_string}) do
      question_mark_code_points = ["?ß", "?ä", "?ö", "?ü", "?_", "?a", "?z"]
      integer_literal_code_points = ["223", "228", "246", "252", "95", "97", "122"]

      Enum.any?(question_mark_code_points, &String.contains?(code_string, &1)) &&
        not Enum.any?(integer_literal_code_points, &String.contains?(code_string, &1))
    end
  end

  check_source "doesn't create binaries from character codes" do
    type :essential
    comment Constants.german_sysadmin_no_string()

    check(%Source{code_ast: code_ast}) do
      {_, no_binary?} =
        code_ast
        |> Macro.postwalk(&remove_sigil_c/1)
        |> Macro.postwalk(true, &no_binary_fun?/2)

      no_binary?
    end
  end

  defp remove_sigil_c({:sigil_c, _, _}) do
    []
  end

  defp remove_sigil_c(node), do: node

  defp no_binary_fun?({:<<>>, _, _} = node, _) do
    {node, false}
  end

  defp no_binary_fun?(node, acc) do
    {node, acc}
  end
end
