defmodule ElixirAnalyzer.ExerciseTest.Feature do
  @doc false
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)

      @feature_tests []
    end
  end

  @doc """
  Store each feature in the @features attribute so we can compile them all at once later
  """
  defmacro feature(description, do: block) do
    feature_data = %{
      name: description,
      forms: [],
      meta: %{
        keep_meta: false
      }
    }

    {_, feature_data} = Macro.prewalk(block, feature_data, &gather_feature_data/2)

    # made into a key-val list for better quoting
    feature_forms = feature_data.forms
    feature_data = Map.delete(feature_data, :forms)
    feature_data = %{feature_data | meta: Map.to_list(feature_data.meta)}
    feature_data = Map.to_list(feature_data)

    quote do
      @feature_tests [
        {unquote(feature_data), unquote(Macro.escape(feature_forms))} | @feature_tests
      ]
    end
  end

  defp gather_feature_data({field, _, [f]} = node, acc)
       when field in [:comment, :type, :find, :status] do
    {node, put_in(acc, [field], f)}
  end

  defp gather_feature_data({:suppress_if, _, [name, condition]} = node, acc) do
    {node, put_in(acc, [:suppress_if], [name, condition])}
  end

  defp gather_feature_data({:depth, _, [f]} = node, acc) when is_integer(f) do
    {node, put_in(acc, [:depth], f)}
  end

  defp gather_feature_data({:meta, _, [{key, _, [value]}]} = node, acc) do
    {node, update_in(acc, [:meta], fn m -> Map.put(m, key, value) end)}
  end

  defp gather_feature_data({:form, _, [[do: form]]} = node, acc) do
    ast =
      unless acc.meta.keep_meta do
        Macro.prewalk(form, fn
          {name, _, param} -> {name, :_ignore, param}
          node -> node
        end)
      else
        form
      end

    {ast, block_params} =
      case ast do
        {:__block__, _, [param]} ->
          {param, false}

        {:__block__, _, [_ | _] = params} ->
          {params, length(params)}

        _ ->
          {ast, false}
      end

    find_ast_string =
      ast
      |> Macro.prewalk(fn
        {atom, meta, param} = node ->
          cond do
            atom == :_ignore -> "_"
            meta == :_ignore -> {atom, "_", param}
            true -> node
          end

        node ->
          node
      end)
      # Turn the AST into a string
      |> inspect()
      # Replace double-quoted ""_"" with "_"
      |> String.replace("\"_\"", "_")

    {node,
     update_in(acc, [:forms], fn fs ->
       [[{:find_ast_string, find_ast_string}, {:block_params, block_params}] | fs]
     end)}
  end

  defp gather_feature_data(node, acc), do: {node, acc}
end
