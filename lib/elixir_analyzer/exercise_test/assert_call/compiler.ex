defmodule ElixirAnalyzer.ExerciseTest.AssertCall.Compiler do
  @moduledoc """
  Provides the logic of the analyzer function `assert_call`

  When transformed at compile-time by `use ElixirAnalyzer.ExerciseTest`, this will place an expression inside
  of an if statement which then returns :pass or :fail as required by `ElixirAnalyzer.ExerciseTest.analyze/4`.
  """

  alias ElixirAnalyzer.ExerciseTest.AssertCall

  def compile(assert_call_data, code_ast) do
    name = assert_call_data.description
    called_fn = Macro.escape(assert_call_data.called_fn)
    calling_fn = Macro.escape(assert_call_data.calling_fn)
    {comment, _} = Code.eval_quoted(assert_call_data.comment)
    should_call = assert_call_data.should_call
    type = assert_call_data.type

    test_description =
      Macro.escape(%{
        name: name,
        comment: comment,
        type: type
      })

    assert_result = assert_expr(code_ast, should_call, called_fn, calling_fn)

    quote do
      if unquote(assert_result) do
        {:pass, unquote(test_description)}
      else
        {:fail, unquote(test_description)}
      end
    end
  end

  defp assert_expr(code_ast, should_call, called_fn, calling_fn) do
    quote do
      (fn
         ast, true ->
           unquote(__MODULE__).assert(ast, unquote(called_fn), unquote(calling_fn))

         ast, false ->
           not unquote(__MODULE__).assert(ast, unquote(called_fn), unquote(calling_fn))
       end).(unquote(code_ast), unquote(should_call))
    end
  end

  def assert(ast, called_fn, calling_fn) do
    acc = %{
      in_function_def: nil,
      found_called: false,
      called_fn: called_fn,
      calling_fn: calling_fn
    }

    ast
    |> Macro.traverse(acc, &annotate/2, &annotate_and_find/2)
    |> handle_traverse_result()
  end

  @doc """
  Handle the final result from the assert function
  """
  @spec handle_traverse_result({any, map()}) :: boolean
  def handle_traverse_result({_, %{found_called: found}}), do: found

  @doc """
  When pre-order traversing, annotate the accumulator that we are now inside of a function definition
  if it matches the calling_fn function signature
  """
  @spec annotate(Macro.t(), map()) :: {Macro.t(), map()}
  def annotate(node, acc) do
    function_def? = function_def?(node)
    name = extract_function_name(node)

    case {function_def?, name} do
      {true, name} ->
        {node, %{acc | in_function_def: name}}

      _ ->
        {node, acc}
    end
  end

  @doc """
  When post-order traversing, annotate the accumulator that we are now leaving a function definition
  """
  @spec annotate_and_find(Macro.t(), map()) :: {Macro.t(), map()}
  def annotate_and_find(node, acc) do
    {node, acc} = find(node, acc)

    if function_def?(node) do
      {node, %{acc | in_function_def: nil}}
    else
      {node, acc}
    end
  end

  @doc """
  While traversing the AST, compare a node to check if it is a function call matching the called_fn
  """
  @spec find(Macro.t(), map()) :: {Macro.t(), map()}
  def find(node, %{found_called: true} = acc), do: {node, acc}

  def find(
        node,
        %{
          called_fn: called_fn,
          calling_fn: calling_fn,
          in_function_def: name
        } = acc
      ) do
    match_called_fn? =
      matching_function_call?(node, called_fn) and not in_function?(name, called_fn)

    match_calling_fn? = in_function?(name, calling_fn) or is_nil(calling_fn)

    if match_called_fn? and match_calling_fn? do
      {node, %{acc | found_called: true}}
    else
      {node, acc}
    end
  end

  @doc """
  compare a node to the function_signature, looking for a match for a called function
  """
  @spec matching_function_call?(Macro.t(), nil | AssertCall.function_signature()) :: boolean()
  def matching_function_call?(_node, nil), do: false

  def matching_function_call?(
        {{:., _, [{:__aliases__, _, module_path}, _name]}, _, _args},
        {module_path, :_}
      ) do
    true
  end

  def matching_function_call?(
        {{:., _, [{:__aliases__, _, module_path}, name]}, _, _args},
        {module_path, name}
      ) do
    true
  end

  def matching_function_call?(
        {name, _, _args},
        {_, name}
      ) do
    true
  end

  def matching_function_call?(_, _), do: false

  @doc """
  compare a node to the function_signature, looking for a match for a called function
  """
  @spec matching_function_def?(Macro.t(), AssertCall.function_signature()) :: boolean()
  def matching_function_def?(_node, nil), do: false

  def matching_function_def?(
        {def_type, _, [{name, _, _args}, [do: {:__block__, _, [_ | _]}]]},
        {_module_path, name}
      )
      when def_type in ~w[def defp]a do
    true
  end

  def matching_function_def?(_, _), do: false

  @doc """
  node is a function definition
  """
  def function_def?({def_type, _, [{name, _, _}, [do: _]]})
      when is_atom(name) and def_type in ~w[def defp]a do
    true
  end

  def function_def?(_node), do: false

  @doc """
  get the name of a function from a function definition node
  """
  def extract_function_name({def_type, _, [{name, _, _}, [do: _]]})
      when is_atom(name) and def_type in ~w[def defp]a,
      do: name

  def extract_function_name(_), do: nil

  @doc """
  compare the name of the function to the function signature, if they match return true
  """
  def in_function?(name, {_module_path, name}), do: true
  def in_function?(_, _), do: false
end
