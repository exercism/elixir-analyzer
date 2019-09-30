defmodule ElixirAnalyzer.ExerciseTest do
  @moduledoc false

  alias ElixirAnalyzer.Submission
  alias ElixirAnalyzer.QuoteUtil

  @doc false
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
      @features []
    end
  end

  #
  # Feature Macro -- Start
  #

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

    feature_data =
      block
      |> Macro.prewalk(feature_data, &gather_feature_data/2)
      # return acc only
      |> elem(1)

    # made into a key-val list for better quoting
    feature_forms = feature_data.forms
    feature_data = Map.delete(feature_data, :forms)
    feature_data = %{feature_data | meta: Map.to_list(feature_data.meta)}
    feature_data = Map.to_list(feature_data)

    quote do
      @features [{unquote(feature_data), unquote(Macro.escape(feature_forms))} | @features]
    end
  end

  defp gather_feature_data({field, _, [f]} = node, acc)
       when field in [:message, :severity, :match, :status] do
    {node, put_in(acc, [field], f)}
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
        {:__block__, _, params} -> {params, length(params)}
        _ -> {ast, false}
      end

    match_ast_string =
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
       [[{:match_ast_string, match_ast_string}, {:block_params, block_params}] | fs]
     end)}
  end

  defp gather_feature_data(node, acc), do: {node, acc}

  #
  #  Feature Macro -- End
  #

  #
  #  Compile @features into features function in the __before_compile__ macro
  #

  defmacro __before_compile__(env) do
    features = Macro.escape(Module.get_attribute(env.module, :features))
    tests_needed_to_approve = Module.get_attribute(env.module, :tests_needed_to_approve, [])

    # ast placeholder for the submission code ast
    code_ast = quote do: code_ast

    # compile each feature to a test
    feature_tests = Enum.map(features, &compile_feature(&1, code_ast))

    quote do
      @spec analyze(Submission.t(), String.t()) :: Submission.t()
      def analyze(s = %Submission{}, code_as_string) do
        case Code.string_to_quoted(code_as_string) do
          {:ok, code_ast} ->
            feature_results = unquote(feature_tests)
            tests_needed_to_approve = unquote(tests_needed_to_approve)

            s
            |> append_test_comments(feature_results)
            |> determine_status(feature_results, tests_needed_to_approve)

          {:error, e} ->
            append_analysis_failure(s, e)
        end
      end

      defp append_test_comments(s = %Submission{}, feature_results) do
        Enum.reduce(feature_results, s, fn
          {:pass, _desc}, s ->
            s

          {:skip, _desc}, s ->
            s

          {:fail, desc}, s when is_map(desc) ->
            if Map.has_key?(desc, :params) do
              Submission.append_comment(s, {desc.message, desc.params})
            else
              Submission.append_comment(s, desc.message)
            end

          _, s ->
            s
        end)
      end

      defp determine_status(s = %Submission{}, feature_results, tests_needed_to_approve) do
        only_passing = fn
          {:pass, _} -> true
          _ -> false
        end

        only_names = fn {_, name} -> name end

        passing_tests =
          feature_results
          |> Enum.filter(only_passing)
          |> Enum.map(only_names)

        approved =
          case tests_needed_to_approve do
            [] -> false

            _  ->
              tests_needed_to_approve
              |> Enum.all?(fn t -> t in passing_tests end)
          end

        disapproved =
          Enum.any?(feature_results, fn
            {:fail, %{severity: :disapprove}} -> true
            _ -> false
          end)

        case {approved, disapproved} do
          {_,    true } -> Submission.disapprove(s)
          {true, false} -> Submission.approve(s)
          _truth_table  -> s
        end
      end

      defp append_analysis_failure(s = %Submission{}, {line, error, token}) do
        make_error = fn
          e, t when is_binary(e) ->
            e <> t

          e, t when is_tuple(e) ->
            [e | rest] = Tuple.to_list(e)

            Enum.join([e, t | rest])
        end

        comment_params = %{line: line, error: make_error.(error, token), token: token}

        Submission.append_comment(s, {"elixir.analysis.quote_error", comment_params})
      end
    end
  end

  def compile_feature({feature_data, feature_forms}, code_ast) do
    name = Keyword.fetch!(feature_data, :name)
    message = Keyword.fetch!(feature_data, :message)
    status = Keyword.get(feature_data, :status, :test)
    severity = Keyword.get(feature_data, :severity, :disapprove)
    match_type = Keyword.get(feature_data, :match, :all)
    match_at_depth = Keyword.get(feature_data, :depth, nil)

    form_expr =
      feature_forms
      |> Enum.map(&compile_form(&1, match_at_depth, code_ast))
      |> Enum.reduce(:start, &combine_compiled_forms(match_type, &1, &2))
      |> handle_combined_compiled_forms(match_type)

    case status do
      :test ->
        quote do
          if unquote(form_expr) do
            {:pass, unquote(name)}
          else
            {:fail,
             %{
               message: unquote(message),
               severity: unquote(severity)
             }}
          end
        end

      :skip ->
        quote do
          {:skip, unquote(name)}
        end
    end
  end

  def compile_form(form, match_at_depth, code_ast) do
    match_ast_string = Keyword.fetch!(form, :match_ast_string)
    block_params = Keyword.fetch!(form, :block_params)

    match_ast = Code.string_to_quoted!(match_ast_string)

    # create the walk function, determined if the form to match
    # is multiple first level entries in a code block
    walk_fn = get_compile_form_prewalk_fn(block_params, match_ast, match_at_depth)

    quote do
      (fn ast ->
         {_, result} = QuoteUtil.prewalk(ast, false, unquote(walk_fn))

         result
       end).(unquote(code_ast))
    end
  end

  defp get_compile_form_prewalk_fn(block_params, match_ast, match_at_depth)
       when is_integer(block_params) do
    quote do
      fn
        # If the node matches a block, then chunk the block contents
        # to the size of the form block, then pattern match on each chunk
        # return true if a match
        {:__block__, _, params} = node, false, depth ->
          matching_depth = unquote(match_at_depth) in [nil, depth]

          cond do
            matching_depth and is_list(params) ->
              match =
                params
                |> Enum.chunk_every(unquote(block_params), 1, :discard)
                |> Enum.reduce(false, fn
                  chunk, false ->
                    match?(unquote(match_ast), chunk)

                  _chunk, true ->
                    true
                end)

              {node, match}

            true ->
              {node, false}
          end

        # If not a block, then we know it can't match, so pass
        # along the accumulator
        node, val, _depth ->
          {node, val}
      end
    end
  end

  defp get_compile_form_prewalk_fn(false, match_ast, match_at_depth) do
    quote do
      fn
        node, false, depth ->
          # IO.inspect({node, depth, inspect(unquote(Macro.escape(match_ast))), unquote(match_at_depth)}, label: ">>>")

          matching_depth = unquote(match_at_depth) in [nil, depth]

          cond do
            matching_depth ->
              {node, match?(unquote(match_ast), node)}

            true ->
              {node, false}
          end

        node, true, _depth ->
          {node, true}
      end
    end
  end

  def combine_compiled_forms(:any, form, :start) do
    # start the disjuction with false
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

  def handle_combined_compiled_forms(combined_expr, match_type) do
    case match_type do
      type when type in [:all, :any] -> combined_expr
      type when type in [:none] -> quote do: unquote(combined_expr) == 0
      type when type in [:one] -> quote do: unquote(combined_expr) == 1
    end
  end
end
