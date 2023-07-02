defmodule ElixirAnalyzer.TestSuite.DNAEncoding do
  @moduledoc """
  This is an exercise analyzer extension module for the DNA Encoding concept exercise
  """

  use ElixirAnalyzer.ExerciseTest
  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Source

  assert_no_call "does not call any Enum functions" do
    type :essential
    called_fn module: Enum, name: :_
    comment Constants.dna_encoding_use_recursion()
  end

  assert_no_call "does not call any Stream functions" do
    type :essential
    called_fn module: Stream, name: :_
    comment Constants.dna_encoding_use_recursion()
  end

  assert_no_call "does not call any List functions" do
    type :essential
    called_fn module: List, name: :_
    comment Constants.dna_encoding_use_recursion()
  end

  assert_no_call "does not use list comprehensions" do
    type :essential
    called_fn name: :for
    comment Constants.dna_encoding_use_recursion()
  end

  check_source "uses tail call recursion" do
    type :essential
    suppress_if "does not call any Enum functions", :fail
    suppress_if "does not call any Stream functions", :fail
    suppress_if "does not call any List functions", :fail
    suppress_if "does not use list comprehensions", :fail
    comment Constants.dna_encoding_use_tail_call_recursion()

    check(%Source{code_ast: code_ast}) do
      {_, tail_call_recursive_functions} =
        Macro.prewalk(
          code_ast,
          [],
          fn node, acc -> find_tail_call_recursive_functions(node, acc) end
        )

      tail_call_recursive_functions = Enum.uniq(tail_call_recursive_functions)

      {_, all_recursive_functions} =
        Macro.prewalk(
          code_ast,
          [],
          fn node, acc -> find_all_recursive_functions(node, acc) end
        )

      all_recursive_functions = Enum.uniq(all_recursive_functions)

      non_tail_call_recursive_functions = all_recursive_functions -- tail_call_recursive_functions

      if non_tail_call_recursive_functions != [] || tail_call_recursive_functions == [] do
        {false,
         %{
           non_tail_call_recursive_functions:
             format_function_names(non_tail_call_recursive_functions),
           tail_call_recursive_functions: format_function_names(tail_call_recursive_functions)
         }}
      else
        true
      end
    end
  end

  defp format_function_names(list) do
    if list == [] do
      "none"
    else
      Enum.map(list, fn {name, arity} -> "`#{name}/#{arity}`" end)
      |> Enum.join(", ")
    end
  end

  defp find_tail_call_recursive_functions(node, acc) do
    acc =
      case node do
        {op, _meta1, [{:when, _meta2, [{fn_name, _meta3, args} | _]}, opts]}
        when op in [:def, :defp] ->
          check_if_function_tail_call_recursive(acc, fn_name, args, opts)

        {op, _meta1, [{fn_name, _meta2, args}, opts]} when op in [:def, :defp] ->
          check_if_function_tail_call_recursive(acc, fn_name, args, opts)

        _ ->
          acc
      end

    {node, acc}
  end

  defp check_if_function_tail_call_recursive(acc, fn_name, args, opts) do
    fn_arity = length(args)

    last_call_in_function_def =
      case opts[:do] do
        {:__block, _, calls} when is_list(calls) ->
          List.last(calls)

        calls when is_list(calls) ->
          List.last(calls)

        call ->
          call
      end

    case last_call_in_function_def do
      {^fn_name, _meta3, args} when length(args) == fn_arity ->
        [{fn_name, fn_arity} | acc]

      _ ->
        acc
    end
  end

  defp find_all_recursive_functions(node, acc) do
    acc =
      case node do
        {op, _meta1, [{:when, _meta2, [{fn_name, _meta3, args} | _]}, opts]}
        when op in [:def, :defp] ->
          check_if_function_recursive(acc, fn_name, args, opts)

        {op, _meta1, [{fn_name, _meta2, args}, opts]} when op in [:def, :defp] ->
          check_if_function_recursive(acc, fn_name, args, opts)

        _ ->
          acc
      end

    {node, acc}
  end

  defp check_if_function_recursive(acc, fn_name, args, opts) do
    fn_arity = length(args)

    {_, any_nested_recursive_calls?} =
      Macro.prewalk(opts[:do], false, fn node, acc ->
        case node do
          {^fn_name, _, args} when length(args) == fn_arity -> {node, true}
          _ -> {node, acc}
        end
      end)

    if any_nested_recursive_calls? do
      [{fn_name, fn_arity} | acc]
    else
      acc
    end
  end
end
