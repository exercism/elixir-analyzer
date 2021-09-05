defmodule ElixirAnalyzer.ExerciseTest.Feature.Compiler do
  @moduledoc false

  alias ElixirAnalyzer.QuoteUtil
  alias ElixirAnalyzer.Comment
  alias ElixirAnalyzer.ExerciseTest.Feature.Compiler

  def compile({feature_data, feature_forms}, code_ast) do
    name = Keyword.fetch!(feature_data, :name)
    {comment, _} = Code.eval_quoted(Keyword.fetch!(feature_data, :comment))
    status = Keyword.get(feature_data, :status, :test)
    type = Keyword.get(feature_data, :type, :informative)
    find_type = Keyword.get(feature_data, :find, :all)
    find_at_depth = Keyword.get(feature_data, :depth, nil)
    suppress_if = Keyword.get(feature_data, :suppress_if, false)

    form_expr =
      feature_forms
      |> Enum.map(&compile_form(&1, find_at_depth, code_ast))
      |> Enum.reduce(:start, &combine_compiled_forms(find_type, &1, &2))
      |> handle_combined_compiled_forms(find_type)

    test_description =
      Macro.escape(%Comment{
        name: name,
        comment: comment,
        status: status,
        type: type,
        suppress_if: suppress_if
      })

    case status do
      :test ->
        quote do
          if unquote(form_expr) do
            {:pass, unquote(test_description)}
          else
            {:fail, unquote(test_description)}
          end
        end

      :skip ->
        quote do
          {:skip, unquote(test_description)}
        end
    end
  end

  def compile_form(form, find_at_depth, code_ast) do
    find_ast = Keyword.fetch!(form, :find_ast)
    block_params = Keyword.fetch!(form, :block_params)

    find_ast = Macro.escape(find_ast)

    # create the walk function, determined if the form to find
    # is multiple first level entries in a code block
    walk_fn = get_compile_form_prewalk_fn(block_params, find_ast, find_at_depth)

    quote do
      (fn ast ->
         {_, result} = QuoteUtil.prewalk(ast, false, unquote(walk_fn))

         result
       end).(unquote(code_ast))
    end
  end

  defp get_compile_form_prewalk_fn(block_params, find_ast, find_at_depth)
       when is_integer(block_params) do
    quote do
      fn
        # If the node matches a block, then chunk the block contents
        # to the size of the form block, then pattern match on each chunk
        # return true if a match
        {:__block__, _, params} = node, false, depth ->
          finding_depth = unquote(find_at_depth) in [nil, depth]

          if finding_depth and is_list(params) do
            found =
              params
              |> Enum.chunk_every(unquote(block_params), 1, :discard)
              |> Enum.reduce(false, fn
                chunk, false ->
                  Compiler.form_match?(unquote(find_ast), chunk)

                _chunk, true ->
                  true
              end)

            {node, found}
          else
            {node, false}
          end

        # If not a block, then we know it can't match, so pass
        # along the accumulator
        node, val, _depth ->
          {node, val}
      end
    end
  end

  defp get_compile_form_prewalk_fn(false, find_ast, find_at_depth) do
    quote do
      fn
        node, false, depth ->
          finding_depth = unquote(find_at_depth) in [nil, depth]

          if finding_depth do
            {node, Compiler.form_match?(unquote(find_ast), node)}
          else
            {node, false}
          end

        node, true, _depth ->
          {node, true}
      end
    end
  end

  def combine_compiled_forms(:any, form, :start) do
    # start the disjunction with false
    combine_compiled_forms(:any, form, quote(do: false))
  end

  def combine_compiled_forms(:any, form, expr) do
    quote do: unquote(form) or unquote(expr)
  end

  def combine_compiled_forms(:all, form, :start) do
    # start the conjunction with true
    combine_compiled_forms(:all, form, quote(do: true))
  end

  def combine_compiled_forms(:all, form, expr) do
    quote do: unquote(form) and unquote(expr)
  end

  def combine_compiled_forms(type, form, :start) when type in [:one, :none] do
    combine_compiled_forms(type, form, quote(do: 0))
  end

  def combine_compiled_forms(type, form, expr) when type in [:one, :none] do
    quote do
      value =
        (fn form_val ->
           if form_val do
             1
           else
             0
           end
         end).(unquote(form))

      value + unquote(expr)
    end
  end

  def handle_combined_compiled_forms(combined_expr, find_type) do
    case find_type do
      type when type in [:all, :any] -> combined_expr
      type when type in [:none] -> quote do: unquote(combined_expr) == 0
      type when type in [:one] -> quote do: unquote(combined_expr) == 1
    end
  end

  def form_match?(item, item) do
    true
  end

  def form_match?({:_ignore, _, _}, _) do
    true
  end

  def form_match?({:_shallow_ignore, _, form_params}, {_, _, params}) do
    form_match?(form_params, params)
  end

  def form_match?([:_ignore], meta) when is_list(meta) do
    true
  end

  def form_match?(
        {:_block_includes, _, [[do: {:__block__, _, form_params}]]},
        {:__block__, _, params}
      ) do
    all_forms_are_found?(form_params, params)
  end

  def form_match?({:_block_includes, _, [[do: form_params]]}, params)
      when is_list(form_params) do
    all_forms_are_found?(form_params, params)
  end

  def form_match?({:_block_includes, _, [[do: form_params]]}, params) do
    case params do
      {:__block__, _, params} ->
        Enum.any?(params, fn param -> form_match?(form_params, param) end)

      _ ->
        form_match?(form_params, params)
    end
  end

  def form_match?(
        {:_block_ends_with, _, [[do: {:__block__, _, form_params}]]},
        {:__block__, _, params}
      ) do
    form_match?(List.last(form_params), List.last(params)) and
      all_forms_are_found?(form_params, params)
  end

  def form_match?({:_block_ends_with, _, [[do: form_params]]}, params)
      when is_list(form_params) do
    form_match?(List.last(form_params), List.last(List.wrap(params))) and
      all_forms_are_found?(form_params, params)
  end

  def form_match?({:_block_ends_with, _, [[do: form_params]]}, params) do
    case params do
      {:__block__, _, block_params} ->
        form_match?(form_params, List.last(block_params))

      _ ->
        form_match?(form_params, List.last(List.wrap(params)))
    end
  end

  # Pipes are a special case, when pipes are in the form, they must be in the code
  def form_match?({:|>, form_meta, [form_params, form_function]}, line) do
    case line do
      {:|>, meta, [params, function]} ->
        form_function = add_parens_to_end_of_pipe(form_function)
        function = add_parens_to_end_of_pipe(function)

        form_match?(form_meta, meta) and form_match?(form_params, params) and
          form_match?(form_function, function)

      _ ->
        false
    end
  end

  # When pipes are not in the form but in the code, we un-pipe the code
  def form_match?(form_params, {:|>, _, [params, {function, function_meta, function_params}]}) do
    if is_atom(function_params) do
      form_match?(form_params, {function, function_meta, List.wrap(params)})
    else
      form_match?(form_params, {function, function_meta, [params | function_params]})
    end
  end

  def form_match?(form_params, params) when is_list(form_params) and is_list(params) do
    length(form_params) == length(params) and
      Enum.zip_with(form_params, params, &form_match?/2)
      |> Enum.all?()
  end

  def form_match?({form_name, form_meta, form_params}, {name, meta, params}) do
    form_match?(form_name, name) and
      form_match?(form_meta, meta) and
      form_match?(form_params, params)
  end

  def form_match?({form_a, form_b}, {a, b}) do
    form_match?(form_a, a) and form_match?(form_b, b)
  end

  def form_match?(_, _) do
    false
  end

  defp all_forms_are_found?(form_params, params) when is_list(form_params) and is_list(params) do
    Enum.reduce_while(params, form_params, fn
      _, [] ->
        {:halt, []}

      line, [form_head | form_tail] = form ->
        {:cont, if(form_match?(form_head, line), do: form_tail, else: form)}
    end)
    |> Enum.empty?()
  end

  defp all_forms_are_found?(form_params, _params) when is_list(form_params) do
    false
  end

  defp add_parens_to_end_of_pipe({name, meta, module}) when is_atom(module) do
    {name, meta, []}
  end

  defp add_parens_to_end_of_pipe(node) do
    node
  end
end
