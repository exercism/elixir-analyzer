defmodule ElixirAnalyzer.QuoteUtil do
  @moduledoc """
  Adaptation from Macro.traverse, Macro.prewalk, Macro.postwalk to provide the tree
  depth to the walk function
  """

  @doc """
  Performs a depth-first traversal of quoted expressions
  using an accumulator.  This also provides how 'deep' the node is in the AST.

  :__block__ wrapper elements are not counted as a layer of depth
  """
  @spec traverse_with_depth(
          Macro.t(),
          any,
          (Macro.t(), any, non_neg_integer -> {Macro.t(), any}),
          (Macro.t(), any, non_neg_integer -> {Macro.t(), any})
        ) :: {Macro.t(), any}
  def traverse_with_depth(ast, acc, pre, post)
      when is_function(pre, 3) and is_function(post, 3) do
    depth = 0
    {ast, acc} = pre.(ast, acc, depth)
    do_traverse_with_depth(ast, acc, depth, pre, post)
  end

  defp do_traverse_with_depth({:__block__, meta, args}, acc, depth, pre, post) do
    {args, acc} = do_traverse_with_depth_args(args, acc, depth, pre, post)
    post.({:__block__, meta, args}, acc, depth)
  end

  defp do_traverse_with_depth({form, meta, args}, acc, depth, pre, post) when is_atom(form) do
    {args, acc} = do_traverse_with_depth_args(args, acc, depth + 1, pre, post)
    post.({form, meta, args}, acc, depth)
  end

  defp do_traverse_with_depth({form, meta, args}, acc, depth, pre, post) do
    {form, acc} = pre.(form, acc, depth)
    {form, acc} = do_traverse_with_depth(form, acc, depth, pre, post)
    {args, acc} = do_traverse_with_depth_args(args, acc, depth, pre, post)
    post.({form, meta, args}, acc, depth)
  end

  defp do_traverse_with_depth({left, right}, acc, depth, pre, post) do
    {left, acc} = pre.(left, acc, depth)
    {left, acc} = do_traverse_with_depth(left, acc, depth, pre, post)
    {right, acc} = pre.(right, acc, depth)
    {right, acc} = do_traverse_with_depth(right, acc, depth, pre, post)
    post.({left, right}, acc, depth)
  end

  defp do_traverse_with_depth(list, acc, depth, pre, post) when is_list(list) do
    {list, acc} = do_traverse_with_depth_args(list, acc, depth, pre, post)
    post.(list, acc, depth)
  end

  defp do_traverse_with_depth(x, acc, depth, _pre, post) do
    post.(x, acc, depth)
  end

  defp do_traverse_with_depth_args(args, acc, _depth, _pre, _post) when is_atom(args) do
    {args, acc}
  end

  defp do_traverse_with_depth_args(args, acc, depth, pre, post) when is_list(args) do
    Enum.map_reduce(args, acc, fn x, acc ->
      {x, acc} = pre.(x, acc, depth)
      do_traverse_with_depth(x, acc, depth, pre, post)
    end)
  end

  @doc """
  Performs a depth-first, pre-order traversal of quoted expressions.
  With depth provided to a function
  """
  @spec prewalk(Macro.t(), (Macro.t(), non_neg_integer -> Macro.t())) :: Macro.t()
  def prewalk(ast, fun) when is_function(fun, 2) do
    elem(prewalk(ast, nil, fn x, nil, d -> {fun.(x, d), nil} end), 0)
  end

  @doc """
  Performs a depth-first, pre-order traversal of quoted expressions
  using an accumulator.
  """
  @spec prewalk(Macro.t(), any, (Macro.t(), any, non_neg_integer -> {Macro.t(), any})) ::
          {Macro.t(), any}
  def prewalk(ast, acc, fun) when is_function(fun, 3) do
    traverse_with_depth(ast, acc, fun, fn x, a, _d -> {x, a} end)
  end

  @doc """
  Performs a depth-first, post-order traversal of quoted expressions.
  """
  @spec postwalk(Macro.t(), (Macro.t(), non_neg_integer -> Macro.t())) :: Macro.t()
  def postwalk(ast, fun) when is_function(fun, 2) do
    elem(postwalk(ast, nil, fn x, nil, d -> {fun.(x, d), nil} end), 0)
  end

  @doc """
  Performs a depth-first, post-order traversal of quoted expressions
  using an accumulator.
  """
  @spec postwalk(Macro.t(), any, (Macro.t(), any, non_neg_integer -> {Macro.t(), any})) ::
          {Macro.t(), any}
  def postwalk(ast, acc, fun) when is_function(fun, 3) do
    traverse_with_depth(ast, acc, fn x, a, _d -> {x, a} end, fun)
  end
end
