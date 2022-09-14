defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.FunctionAnnotationOrder do
  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Comment

  @moduledoc """
  Report the first function/macro/guard where @spec module attribute comes before the
  @doc module attribute

  Common check to be run on every single solution.
  """
  @def_ops [:def, :defmacro]

  def run(ast) do
    acc = %{module: [], definitions: %{[] => []}}
    {_, %{definitions: definitions}} = Macro.traverse(ast, acc, &enter_node/2, &exit_node/2)

    definitions |> Enum.flat_map(fn {_module, ops} ->  ops |> Enum.reverse() |> chunk_definitions() |> merge_definitions()  end)
    |> check_errors()
  end

  def enter_node({:defmodule, _, [{:__aliases__, _, aliases}, _]} = ast, acc) do
    module = [aliases | acc.module]
    definitions = Map.put(acc.definitions, module, [])
    {ast, %{module: module, definitions: definitions}}
  end

  def enter_node({:@, _, [{:spec, _, [{:"::", _, [{fn_name, _, _} | _]}]} | _]} = ast, acc) do
    definitions = Map.update!(acc.definitions, acc.module, &[{:spec, fn_name} | &1])
    {ast, %{acc | definitions: definitions}}
  end

  def enter_node({:@, _, [{:spec, _, [{fn_name, _, _}]}]} = ast, acc) do
    definitions = Map.update!(acc.definitions, acc.module, &[{:spec, fn_name} | &1])
    {ast, %{acc | definitions: definitions}}
  end

  def enter_node({:@, _, [{:doc, _, _}]} = ast, acc) do
    definitions = Map.update!(acc.definitions, acc.module, &[:doc | &1])
    {ast, %{acc | definitions: definitions}}
  end

  def enter_node({op, _, [{:when, _, [{fn_name, _, _} | _]} | _]} = ast, acc)
       when op in @def_ops do
    definitions = Map.update!(acc.definitions, acc.module, &[{op, fn_name} | &1])
    {ast, %{acc | definitions: definitions}}
  end

  def enter_node({op, _, [{fn_name, _, _} | _]} = ast, acc)
       when op in @def_ops do
    definitions = Map.update!(acc.definitions, acc.module, &[{op, fn_name} | &1])
    {ast, %{acc | definitions: definitions}}
  end

  def enter_node(ast, acc) do
    {ast, acc}
  end

  def exit_node({:defmodule, _, _} = ast, %{module: module} = acc) do
    {ast, %{acc | module: tl(module)}}
  end

  def exit_node(ast, acc) do
    {ast, acc}
  end

  def chunk_definitions(definitions) do
    chunk_fun = fn
      {op, name}, %{name: nil, operations: ops} = chunk ->
        {:cont, %{chunk | name: name, operations: [op | ops]}}

      {op, name}, %{name: name, operations: ops} = chunk ->
        {:cont, %{chunk | operations: [op | ops]}}

      {op, name}, %{operations: ops} = chunk ->
        {:cont, %{chunk | operations: Enum.reverse(ops)}, %{name: name, operations: [op]}}

      :doc, %{operations: ops} = chunk ->
        {:cont, %{chunk | operations: Enum.reverse(ops)}, %{name: nil, operations: [:doc]}}
    end

    Enum.chunk_while(
      definitions,
      %{name: nil, operations: []},
      chunk_fun,
      &{:cont, %{&1 | operations: Enum.reverse(&1.operations)}, nil}
    )
  end

  def merge_definitions(definitions) do
    Enum.reduce(
      definitions,
      [],
      fn
        %{name: def_name} = definition, [%{name: chunk_name} = chunk | chunks]
        when is_nil(def_name) or def_name == chunk_name ->
          [%{chunk | operations: chunk.operations ++ definition.operations} | chunks]

        definition, chunks ->
          [definition | chunks]
      end
    )
  end

  def check_errors(attrs) do
    if Enum.any?(attrs, &check_wrong_order/1) do
      [
        {:fail,
         %Comment{
           type: :informative,
           name: Constants.solution_function_annotation_order(),
           comment: Constants.solution_function_annotation_order()
         }}
      ]
    else
      []
    end
  end

  def check_wrong_order(%{operations: operations}) do
    Enum.uniq(operations) not in [
      [],
      [:doc], # first three cases allow for private functions (:def) or macros (:defmacrop) to have a doc, a spec or a doc-spec in the right order
      [:spec],
      [:doc, :spec],
      [:def],
      [:defmacro],
      [:spec, :def],
      [:spec, :defmacro],
      [:doc, :def],
      [:doc, :defmacro],
      [:doc, :spec, :def],
      [:doc, :spec, :defmacro]
    ]
  end
end
