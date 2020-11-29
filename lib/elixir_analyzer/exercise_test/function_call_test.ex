defmodule ElixirAnalyzer.ExerciseTest.FunctionCallTest do
  @doc false
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)

      @function_tests []
    end
  end

  defmacro function_test(description, do: block) do
    # test_data = %{
    #   description: description,
    #   calling_function_module: nil,
    #   calling_function_name: nil,
    #   calling_function_arity: 0,
    #   called_function_module: nil,
    #   called_function_name: nil,
    #   called_function_arity: 0,
    #   should_call: true
    # }

    test_data =
      block
      |> walk_function_test()
      |> Map.put(:description, description)
      |> Map.put_new(:should_call, true)

    quote do
      @function_tests [
        unquote(test_data) | @function_tests
      ]
    end
  end

  def walk_function_test(block, test_data \\ %{}) do
    {_, test_data} = Macro.prewalk(block, test_data, &do_walk_function_test/2)
    test_data
  end

  def do_walk_function_test({type, _, [function_signature]} = node, test_data)
      when type in [:calling_function, :called_function] do
    test_data =
      case parse_fn_signature(function_signature) do
        {_, _, nil} ->
          test_data

        {_, nil, _} ->
          test_data

        {nil, _, _} ->
          test_data

        {module, name, arity} ->
          test_data
          |> Map.put("#{type}_module" |> String.to_atom(), module)
          |> Map.put("#{type}_name" |> String.to_atom(), name)
          |> Map.put("#{type}_arity" |> String.to_atom(), arity)
      end

    {node, test_data}
  end

  def do_walk_function_test({:should_call, _, [value]} = node, test_data)
      when is_boolean(value) do
    {node, Map.put(test_data, :should_call, value)}
  end

  def do_walk_function_test(node, test_data) do
    {node, test_data}
  end

  #

  def parse_fn_signature(function_signature_ast, partial \\ {nil, nil, nil})

  def parse_fn_signature({:/, _, [signature_ast, arity]}, {module, function, _}) do
    parse_fn_signature(signature_ast, {module, function, arity})
  end

  def parse_fn_signature({{:., _, [{_, _, [module]}, function]}, _, _}, {_, _, arity}) do
    parse_fn_signature(nil, {module, function, arity})
  end

  def parse_fn_signature({function, _, Elixir}, {module, _, arity}) do
    {module, function, arity}
  end

  def parse_fn_signature(_, signature) do
    signature
  end
end
