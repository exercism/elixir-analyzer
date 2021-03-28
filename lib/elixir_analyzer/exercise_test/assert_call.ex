defmodule ElixirAnalyzer.ExerciseTest.AssertCall do
  @moduledoc false

  @doc false
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)

      @assert_call_tests []
    end
  end

  @doc """
  Defines a macro which allows a test case to be specified which looks for a
  function call inside of a specific function.
  This macro then collates the block into a map structure resembling:
  test_data = %{
    description: description,
    calling_function_module: %FunctionSignature{}
    called_function_module: %FunctionSignature{}
    should_call: true
    type: :actionable
    comment: "message"
  }
  """
  defmacro assert_call(description, do: block) do
    parse(description, block, true)
  end

  defmacro assert_no_call(description, do: block) do
    parse(description, block, false)
  end

  defp parse(description, block, should_call) do
    test_data =
      block
      |> walk_assert_call_block()
      |> Map.put(:description, description)
      |> Map.put(:should_call, should_call)
      |> Map.put_new(:type, :informational)
      |> Map.put_new(:calling_fn, nil)

    unless Map.has_key?(test_data, :comment) do
      raise "Comment must be defined for each assert_call test"
    end

    quote do
      @assert_call_tests [
        unquote(Macro.escape(test_data)) | @assert_call_tests
      ]
    end
  end

  defp walk_assert_call_block(block, test_data \\ %{}) do
    {_, test_data} = Macro.prewalk(block, test_data, &do_walk_assert_call_block/2)
    test_data
  end

  defp do_walk_assert_call_block({:calling_fn, _, [function_signature]} = node, test_data) do
    case FunctionSignature.parse(function_signature) do
      %{global: true} = signature ->
        {node, Map.put(test_data, :calling_fn, signature)}

      %{global: false} ->
        raise ElixirAnalyzer.ExerciseTest.AssertCall.SyntaxError,
              "re-specify :calling_fn function with global context"

      _ ->
        raise ElixirAnalyzer.ExerciseTest.AssertCall.SyntaxError,
              "specified :calling_fn function is invalid"
    end
  end

  defp do_walk_assert_call_block({:called_fn, _, [:global, function_signature]} = node, test_data) do
    signature = do_called_fn(function_signature)
    {node, Map.put(test_data, :called_fn, signature)}
  end

  defp do_walk_assert_call_block({:called_fn, _, [:local, function_signature]} = node, test_data) do
    signatures = do_called_fn(function_signature, true)
    {node, Map.put(test_data, :called_fn, signatures)}
  end

  defp do_walk_assert_call_block({:comment, _, [comment]} = node, test_data)
       when is_binary(comment) do
    {node, Map.put(test_data, :comment, comment)}
  end

  defp do_walk_assert_call_block({:type, _, [type]} = node, test_data)
       when type in ~w[essential actionable informational celebratory]a do
    {node, Map.put(test_data, :type, type)}
  end

  defp do_walk_assert_call_block(node, test_data) do
    {node, test_data}
  end

  defp do_called_fn(function_signature, make_local \\ false) do
    case {FunctionSignature.parse(function_signature), make_local} do
      {:error, _} ->
        raise ElixirAnalyzer.ExerciseTest.AssertCall.SyntaxError,
              "specified :calling_fn function signature is invalid"

      {signature, true} ->
        FunctionSignature.convert_to_local(signature)

      {signature, _} ->
        signature
    end
  end
end
