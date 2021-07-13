defmodule ElixirAnalyzer.ExerciseTest.AssertCall do
  @moduledoc false

  @type function_signature() :: {list(atom()), atom()} | {nil, atom()}

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
    :ok = validate_call_block(block, :assert_call)
    parse(description, block, true)
  end

  defmacro assert_no_call(description, do: block) do
    :ok = validate_call_block(block, :assert_no_call)
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

  @supported_expressions [:comment, :type, :calling_fn, :called_fn, :suppress_if]
  defp validate_call_block({:__block__, _, args}, macro_name) do
    Enum.each(args, fn {name, _, _} ->
      if name not in @supported_expressions do
        raise """
        Unsupported expression `#{name}`.
        The macro `#{macro_name}` supports expressions: #{Enum.join(@supported_expressions, ", ")}.
        """
      end
    end)

    :ok
  end

  defp walk_assert_call_block(block, test_data \\ %{}) do
    {_, test_data} = Macro.prewalk(block, test_data, &do_walk_assert_call_block/2)
    test_data
  end

  defp do_walk_assert_call_block({:calling_fn, _, [signature]} = node, test_data) do
    formatted_signature = do_calling_fn(signature)
    {node, Map.put(test_data, :calling_fn, formatted_signature)}
  end

  defp do_walk_assert_call_block({:called_fn, _, [signature]} = node, test_data) do
    formatted_signature = do_called_fn(signature)
    {node, Map.put(test_data, :called_fn, formatted_signature)}
  end

  defp do_walk_assert_call_block({:comment, _, [comment]} = node, test_data) do
    {node, Map.put(test_data, :comment, comment)}
  end

  defp do_walk_assert_call_block({:type, _, [type]} = node, test_data)
       when type in ~w[essential actionable informational celebratory]a do
    {node, Map.put(test_data, :type, type)}
  end

  defp do_walk_assert_call_block({:suppress_if, _, [name, condition]} = node, test_data) do
    {node, Map.put(test_data, :suppress_if, {name, condition})}
  end

  defp do_walk_assert_call_block(node, test_data) do
    {node, test_data}
  end

  @spec do_calling_fn(Keyword.t()) :: function_signature()
  defp do_calling_fn(function_signature) do
    case validate_signature(function_signature) do
      {nil, _} ->
        raise ArgumentError, "calling function signature requires :module to be an atom"

      signature ->
        signature
    end
  end

  @spec do_called_fn(Keyword.t()) :: function_signature()
  defp do_called_fn(function_signature) do
    validate_signature(function_signature)
  end

  @spec validate_signature(Keyword.t()) :: function_signature()
  defp validate_signature(function_signature) do
    function_signature =
      function_signature
      |> validate_module()
      |> validate_name()

    {function_signature[:module], function_signature[:name]}
  end

  defp validate_module(signature) do
    module =
      case signature[:module] do
        nil ->
          nil

        # For erlang libraries: import :math
        module when is_atom(module) ->
          module

        {:__aliases__, _, module} ->
          module

        x ->
          raise ArgumentError,
                "calling function signature requires :module to be nil or a module atom, got: #{inspect(x)}"
      end

    Keyword.put(signature, :module, module)
  end

  defp validate_name(signature) do
    module =
      case signature[:name] do
        name when is_atom(name) ->
          name

        x ->
          raise ArgumentError,
                "calling function signature requires :name to be an atom, got: #{inspect(x)}"
      end

    Keyword.put(signature, :name, module)
  end
end
