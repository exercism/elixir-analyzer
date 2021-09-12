defmodule ElixirAnalyzer.ExerciseTest.AssertCall.Compiler do
  @moduledoc """
  Provides the logic of the analyzer function `assert_call`

  When transformed at compile-time by `use ElixirAnalyzer.ExerciseTest`, this will place an expression inside
  of an if statement which then returns :pass or :fail as required by `ElixirAnalyzer.ExerciseTest.analyze/4`.
  """

  alias ElixirAnalyzer.ExerciseTest.AssertCall
  alias ElixirAnalyzer.Comment

  def compile(assert_call_data, code_ast) do
    name = assert_call_data.description
    called_fn = Macro.escape(assert_call_data.called_fn)
    calling_fn = Macro.escape(assert_call_data.calling_fn)
    {comment, _} = Code.eval_quoted(assert_call_data.comment)
    should_call = assert_call_data.should_call
    type = assert_call_data.type
    suppress_if = Map.get(assert_call_data, :suppress_if, false)

    test_description =
      Macro.escape(%Comment{
        name: name,
        comment: comment,
        type: type,
        suppress_if: suppress_if
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
      in_module: nil,
      in_function_def: nil,
      in_function_modules: %{},
      modules_in_scope: %{},
      found_called: false,
      called_fn: called_fn,
      calling_fn: calling_fn,
      function_call_tree: %{}
    }

    ast
    |> Macro.traverse(acc, &annotate/2, &annotate_and_find/2)
    |> handle_traverse_result()
  end

  @doc """
  Handle the final result from the assert function
  """
  @spec handle_traverse_result({any, map()}) :: boolean
  def handle_traverse_result({_, %{found_called: found, calling_fn: calling_fn} = acc}) do
    found or (not is_nil(calling_fn) and indirect_call?(acc))
  end

  @doc """
  When pre-order traversing, annotate the accumulator that we are now inside of a function definition
  if it matches the calling_fn function signature
  """
  @spec annotate(Macro.t(), map()) :: {Macro.t(), map()}
  def annotate(node, acc) do
    acc =
      acc
      |> track_aliases(node)
      |> track_imports(node)
      |> track_all_functions(node)

    cond do
      module_def?(node) -> {node, %{acc | in_module: extract_module_name(node)}}
      function_def?(node) -> {node, %{acc | in_function_def: extract_function_name(node)}}
      true -> {node, acc}
    end
  end

  @doc """
  When post-order traversing, annotate the accumulator that we are now leaving a function definition
  """
  @spec annotate_and_find(Macro.t(), map()) :: {Macro.t(), map()}
  def annotate_and_find(node, acc) do
    {node, acc} = find(node, acc)

    cond do
      module_def?(node) -> {node, %{acc | in_module: nil}}
      function_def?(node) -> {node, %{acc | in_function_def: nil, in_function_modules: %{}}}
      true -> {node, acc}
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
          in_module: module,
          modules_in_scope: modules_in_scope,
          in_function_modules: in_function_modules,
          called_fn: called_fn,
          calling_fn: calling_fn,
          in_function_def: name,
          function_call_tree: tree
        } = acc
      ) do
    modules = Map.merge(modules_in_scope, in_function_modules)

    match_called_fn? =
      matching_function_call?(node, called_fn, modules) and
        not in_function?({module, name}, called_fn)

    match_calling_fn? = in_function?({module, name}, calling_fn) or is_nil(calling_fn)

    cond do
      match_called_fn? and match_calling_fn? ->
        {node, %{acc | found_called: true}}

      match_called_fn? ->
        {node, %{acc | function_call_tree: Map.put(tree, {module, name}, [called_fn])}}

      true ->
        {node, acc}
    end
  end

  @doc """
  compare a node to the function_signature, looking for a match for a called function
  """
  @spec matching_function_call?(
          Macro.t(),
          nil | AssertCall.function_signature(),
          %{[atom] => [atom] | keyword()}
        ) :: boolean()
  def matching_function_call?(_node, nil, _), do: false

  # For erlang libraries: :math._ or :math.pow
  def matching_function_call?(
        {{:., _, [module_path, name]}, _, _args},
        {module_path, search_name},
        _modules
      )
      when search_name in [:_, name] do
    true
  end

  # No module path in search
  def matching_function_call?({name, _, _args}, {nil, name}, _modules) do
    true
  end

  # Module path in AST
  def matching_function_call?(
        {{:., _, [{:__aliases__, _, [head | tail] = ast_path}, name]}, _, _args},
        {module_path, search_name},
        modules
      )
      when search_name in [:_, name] do
    # Searching for A.B.C.function()
    cond do
      # Same path: A.B.C.function()
      ast_path == module_path -> true
      # aliased: alias A.B ; B.C.function()
      List.wrap(modules[[head]]) ++ tail == List.wrap(module_path) -> true
      # imported: import A.B ; C.function()
      Map.has_key?(modules, List.wrap(module_path) -- ast_path) -> true
      true -> false
    end
  end

  # No module path in AST
  def matching_function_call?({name, _, args}, {module_path, search_name}, modules)
      when is_list(args) and search_name in [:_, name] do
    case modules[List.wrap(module_path)] do
      nil -> false
      imported -> {name, length(args)} in imported
    end
  end

  def matching_function_call?(_, _, _), do: false

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
  node is a module definition
  """
  def module_def?({:defmodule, _, [{:__aliases__, _, _}, [do: _]]}), do: true
  def module_def?(_node), do: false

  @doc """
  get the name of a module from a module definition node
  """
  def extract_module_name({:defmodule, _, [{:__aliases__, _, name}, [do: _]]}),
    do: name

  def extract_module_name(_), do: nil

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
  def in_function?({module, name}, {module, name}), do: true
  def in_function?({_, name}, {nil, name}), do: true
  def in_function?(_, _), do: false

  # track_imports

  # import an Erlang module without options
  defp track_imports(acc, {:import, _, [module]}) when is_atom(module) do
    paths = [{[module], module.module_info(:exports)}]
    track_modules(acc, paths)
  end

  # import an Erlang module with only: :functions
  defp track_imports(acc, {:import, _, [module, [only: :functions]]}) when is_atom(module) do
    paths = [{[module], module.module_info(:exports)}]
    track_modules(acc, paths)
  end

  # import Elixir module without options
  defp track_imports(acc, {:import, _, [module_paths]}) do
    paths =
      get_import_paths(module_paths)
      |> Enum.map(fn path ->
        module = Module.concat(path)

        case Code.ensure_loaded(module) do
          {:module, _} -> {path, module.__info__(:functions) ++ module.__info__(:macros)}
          {:error, _} -> {path, []}
        end
      end)

    track_modules(acc, paths)
  end

  # import module with :only and a list of functions
  defp track_imports(acc, {:import, _, [module_path, [only: only]]}) when is_list(only) do
    paths =
      get_import_paths(module_path)
      |> Enum.map(fn path -> {path, only} end)

    track_modules(acc, paths)
  end

  # import with :except
  defp track_imports(acc, {:import, _, [module_path, [except: except]]}) do
    %{modules_in_scope: modules} = track_imports(acc, {:import, [], [module_path]})

    paths = Enum.map(modules, fn {path, functions} -> {path, functions -- except} end)

    track_modules(acc, paths)
  end

  # import Elixir module with only: :functions or only: :macros
  defp track_imports(acc, {:import, _, [module_path, [only: functions_or_macros]]}) do
    paths =
      get_import_paths(module_path)
      |> Enum.map(fn path ->
        module = Module.concat(path)

        case Code.ensure_loaded(module) do
          {:module, _} -> {path, module.__info__(functions_or_macros)}
          {:error, _} -> {path, []}
        end
      end)

    track_modules(acc, paths)
  end

  defp track_imports(acc, _) do
    acc
  end

  # get_import_paths
  defp get_import_paths({:__aliases__, _, path}) do
    [path]
  end

  defp get_import_paths({{:., _, [root, :{}]}, _, branches}) do
    [root_path] = get_import_paths(root)

    for branch <- branches,
        path <- get_import_paths(branch) do
      root_path ++ path
    end
  end

  defp get_import_paths(path) when is_atom(path) do
    [[path]]
  end

  # track_aliases
  defp track_aliases(acc, {:alias, _, [module_path]}) do
    paths = get_alias_paths(module_path)
    track_modules(acc, paths)
  end

  defp track_aliases(acc, {:alias, _, [module_path, [as: {:__aliases__, _, [alias]}]]}) do
    paths = get_alias_paths(module_path) |> Enum.map(fn {_, path} -> {[alias], path} end)
    track_modules(acc, paths)
  end

  defp track_aliases(acc, _) do
    acc
  end

  # get_alias_paths
  defp get_alias_paths({:__aliases__, _, path}) do
    [{[List.last(path)], path}]
  end

  defp get_alias_paths({{:., _, [root, :{}]}, _, branches}) do
    [{_, root_path}] = get_alias_paths(root)

    for branch <- branches,
        {last, full_path} <- get_alias_paths(branch) do
      {last, root_path ++ full_path}
    end
  end

  defp get_alias_paths(path) when is_atom(path) do
    [{[path], [path]}]
  end

  # track modules
  defp track_modules(acc, module_paths) do
    Enum.reduce(module_paths, acc, fn {alias, full_path}, acc ->
      if acc.in_function_def,
        do: %{acc | in_function_modules: Map.put(acc.in_function_modules, alias, full_path)},
        else: %{acc | modules_in_scope: Map.put(acc.modules_in_scope, alias, full_path)}
    end)
  end

  # track all called functions
  def track_all_functions(
        %{function_call_tree: tree, in_module: module, in_function_def: name} = acc,
        {_, _, _} = function
      )
      when not is_nil(name) do
    called =
      case function do
        {:., _, [{:__MODULE__, _, _}, fn_name]} -> {module, fn_name}
        {:., _, [{:__aliases__, _, fn_module}, fn_name]} -> {fn_module, fn_name}
        {fn_name, _, _} -> {module, fn_name}
      end

    %{acc | function_call_tree: Map.update(tree, {module, name}, [called], &[called | &1])}
  end

  def track_all_functions(acc, _node), do: acc

  # Check if a function was called through helper functions
  def indirect_call?(%{called_fn: called_fn, calling_fn: calling_fn, function_call_tree: tree}) do
    cond do
      # calling_fn wasn't defined in the code, or was searched already
      is_nil(tree[calling_fn]) ->
        false

      # calling_fn directly called called_fn
      called_fn in tree[calling_fn] ->
        true

      # calling_fn didn't call called_fn, recursively check if other called functions did
      true ->
        Enum.any?(
          tree[calling_fn],
          &indirect_call?(%{
            called_fn: called_fn,
            calling_fn: &1,
            # Remove tree branch since we know it doesn't call called_fn
            function_call_tree: Map.delete(tree, calling_fn)
          })
        )
    end
  end
end
