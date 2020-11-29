defmodule FunctionSignature do
  @enforce_keys [:module_path, :name, :arity]
  defstruct [:module_path, :name, :arity]

  defmodule IncompleteFunctionSignatureError do
    defexception message: "function signature incomplete"
  end

  defimpl String.Chars do
    def to_string(function_signature) do
      module =
        function_signature.module_path
        |> Enum.join(".")

      "#{module}.#{function_signature.name}/#{function_signature.arity}"
    end
  end

  def parse(ast, opts \\ [local: false]) do
    case do_parse(ast, opts) do
      {nil, nil, nil} ->
        raise IncompleteFunctionSignatureError

      {_, nil, nil} ->
        raise IncompleteFunctionSignatureError

      {nil, _, nil} ->
        raise IncompleteFunctionSignatureError

      {nil, nil, _} ->
        raise IncompleteFunctionSignatureError

      {_, _, nil} ->
        raise IncompleteFunctionSignatureError, "missing function arity from function signature"

      {_, nil, _} ->
        raise IncompleteFunctionSignatureError, "missing function name from function signature"

      {nil, _, _} ->
        raise IncompleteFunctionSignatureError, "missing function module from function signature"

      {module_path, name, arity} ->
        %__MODULE__{module_path: module_path, name: name, arity: arity}
    end
  end

  defp do_parse(ast, opts) do
    local = Keyword.get(opts, :local, false)

    if local do
      parse_local(ast, {nil, nil, nil})
    else
      parse_global(ast, {nil, nil, nil})
    end
  end

  @doc false
  defp parse_local(_ast, parted) do
    parted
  end

  @doc false
  defp parse_global({:/, _, [signature_ast, arity]}, {module, function, _}) do
    parse_global(signature_ast, {module, function, arity})
  end

  defp parse_global({{:., _, [{:__aliases__, _, module_path}, function]}, _, _}, {_, _, arity}) do
    parse_global(nil, {module_path, function, arity})
  end

  defp parse_global({function, _, Elixir}, {module, _, arity}) do
    {module, function, arity}
  end

  defp parse_global(_, signature) do
    signature
  end
end
