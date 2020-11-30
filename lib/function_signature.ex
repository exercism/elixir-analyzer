defmodule FunctionSignature do
  @enforce_keys [:global, :name, :arity]
  defstruct [:module_path, :global, :name, :arity]

  defmodule IncompleteFunctionSignatureError do
    defexception message: "function signature incomplete"
  end

  defimpl String.Chars do
    def to_string(%{global: true} = signature) do
      module =
        signature.module_path
        |> Enum.join(".")

      "&#{module}.#{signature.name}/#{signature.arity}"
    end

    def to_string(%{global: false} = signature) do
      "&#{signature.name}/#{signature.arity}"
    end
  end

  def convert_to_local(%__MODULE__{} = signature) do
    %{signature | global: false, module_path: nil}
  end

  def parse(ast) do
    case do_parse(ast) do
      {:global, module_path, name, arity} ->
        %__MODULE__{global: true, module_path: module_path, name: name, arity: arity}

      {:local, _, name, arity} ->
        %__MODULE__{global: false, name: name, arity: arity}

      _ ->
        raise IncompleteFunctionSignatureError
    end
  end

  defp do_parse(
         {:&, _, [{:/, _, [{{:., _, [{:__aliases__, _, module_path}, name]}, _, _}, arity]}]}
       ) do
    {:global, module_path, name, arity}
  end

  defp do_parse({:&, _, [{:/, _, [{name, _, Elixir}, arity]}]}) do
    {:local, nil, name, arity}
  end

  defp do_parse(_) do
    :error
  end
end
