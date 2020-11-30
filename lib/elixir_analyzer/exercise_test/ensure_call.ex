defmodule ElixirAnalyzer.ExerciseTest.EnsureCall do
  @moduledoc false

  @doc false
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)

      @ensure_call_tests []
    end
  end

  @doc """
  Defines a macro which allows a test case to be specified which looks for a
  function call inside of a specific function.

  This macro then collates the block into a map structure resembling:

  test_data = %{
    description: description,
    calling_function_module: %FunctionSignature{}
    called_function_module: [%FunctionSignature{}]
    should_be_present: true
  }
  """
  defmacro ensure_call(description, do: block) do
    test_data =
      block
      |> walk_ensure_call_block()
      |> Map.put(:description, description)
      |> Map.put_new(:should_be_present, true)

    quote do
      @ensure_call_tests [
        unquote(Macro.escape(test_data)) | @ensure_call_tests
      ]
    end
  end

  def walk_ensure_call_block(block, test_data \\ %{}) do
    {_, test_data} = Macro.prewalk(block, test_data, &do_walk_ensure_call_block/2)
    test_data
  end

  def do_walk_ensure_call_block({:called_from, _, [function_signature]} = node, test_data) do
    case FunctionSignature.parse(function_signature) do
      %{global: true} = signature ->
        {node, Map.put(test_data, :called_from, signature)}

      %{global: false} ->
        raise ElixirAnalyzer.ExerciseTest.EnsureCall.SyntaxError,
              "re-specify :called_from function with global context"

      _ ->
        raise ElixirAnalyzer.ExerciseTest.EnsureCall.SyntaxError,
              "specified :called_from function is invalid"
    end
  end

  def do_walk_ensure_call_block({:global_call, _, function_signatures} = node, test_data) do
    signatures = Enum.map(function_signatures, &FunctionSignature.parse/1)

    Enum.each(signatures, fn
      %{global: false} ->
        raise ElixirAnalyzer.ExerciseTest.EnsureCall.SyntaxError,
              "re-specify :called_from function with global context"

      :error ->
        raise ElixirAnalyzer.ExerciseTest.EnsureCall.SyntaxError,
              "specified :global_call attribute is invalid"

      _ ->
        nil
    end)

    {node, Map.put(test_data, :global_call, signatures)}
  end

  def do_walk_ensure_call_block({:local_call, _, function_signatures} = node, test_data) do
    signatures =
      function_signatures
      |> Enum.map(&FunctionSignature.parse/1)
      |> Enum.map(fn
        %{global: true} = signature -> FunctionSignature.convert_to_local(signature)
        signature -> signature
      end)

    Enum.each(signatures, fn
      :error ->
        raise ElixirAnalyzer.ExerciseTest.EnsureCall.SyntaxError,
              "specified :local_call attribute is invalid"

      _ ->
        nil
    end)

    {node, Map.put(test_data, :local_call, signatures)}
  end

  def do_walk_ensure_call_block({:should_be_present, _, [value]} = node, test_data)
      when is_boolean(value) do
    {node, Map.put(test_data, :should_be_present, value)}
  end

  def do_walk_ensure_call_block(node, test_data) do
    {node, test_data}
  end

  #
end
