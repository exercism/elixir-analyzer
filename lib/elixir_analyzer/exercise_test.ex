defmodule ElixirAnalyzer.ExerciseTest do
  @moduledoc false

  alias ElixirAnalyzer.Submission
  alias ElixirAnalyzer.QuoteUtil
  alias ElixirAnalyzer.Constants

  @doc false
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
      @feature_tests []
    end
  end

  #
  # Feature Macro -- Start
  #

  @doc """
  Store each feature in the @features attribute so we can compile them all at once later
  """
  defmacro feature_test(description, do: block) do
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
      @feature_tests [{unquote(feature_data), unquote(Macro.escape(feature_forms))} | @feature_tests]
    end
  end

  defp gather_feature_data({field, _, [f]} = node, acc)
       when field in [:comment, :on_fail, :find, :status] do
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
        {:__block__, _, params} -> {params, length(params)}
        _ -> {ast, false}
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

  #
  #  Feature Macro -- End
  #

  #
  #  Compile @feature_tests into features function in the __before_compile__ macro
  #

  defmacro __before_compile__(env) do
    feature_test_data = Macro.escape(Module.get_attribute(env.module, :feature_tests)) #|> IO.inspect(label: "115")
    auto_approvable = Module.get_attribute(env.module, :auto_approvable, false)

    # ast placeholder for the submission code ast
    code_ast = quote do: code_ast

    # compile each feature to a test
    feature_tests = Enum.map(feature_test_data, &compile_feature(&1, code_ast))

    quote do
      @spec analyze(Submission.t(), String.t()) :: Submission.t()
      def analyze(s = %Submission{}, code_as_string) do
        case Code.string_to_quoted(code_as_string) do
          {:ok, code_ast} ->
            feature_results = unquote(feature_tests)
            feature_results = filter_suppressed_results(feature_results)

            auto_approvable = unquote(auto_approvable)

            s
            |> append_test_comments(feature_results)
            |> determine_status(feature_results, auto_approvable)

          {:error, e} ->
            append_analysis_failure(s, e)
        end
      end

      defp filter_suppressed_results(feature_results) do
        feature_results
        |> Enum.filter(fn
          {_test_result, %{suppress_if: condition}} when condition !== false ->
            [suppress_on_test_name, suppress_on_result] = condition

            suppressed =
              Enum.any?(feature_results, fn {result, test} ->
                case {result, test.name} do
                  {^suppress_on_result, ^suppress_on_test_name} -> true
                  _ -> false
                end
              end)

            # If the test should be suppressed, return false to filter the result
            case suppressed do
              true -> false
              _    -> true
            end

          _result -> true
        end)
      end

      defp append_test_comments(s = %Submission{}, feature_results) do
        Enum.reduce(feature_results, s, fn
          {:pass, _description}, s ->
            s

          {:skip, _description}, s ->
            s

          {:fail, description}, s when is_map(description) ->
            if Map.has_key?(description, :params) do
              Submission.append_comment(s, {description.comment, description.params})
            else
              Submission.append_comment(s, description.comment)
            end

          _, s ->
            s
        end)
      end

      defp determine_status(s = %Submission{}, feature_results, auto_approvable) do
        referred =
          Enum.any?(feature_results, fn
            {:fail, %{on_fail: :refer}} -> true
            _ -> false
          end)

        disapproved =
          Enum.any?(feature_results, fn
            {:fail, %{on_fail: :disapprove}} -> true
            _ -> false
          end)

        approved =
          Enum.all?(feature_results, fn
            {:fail, %{on_fail: :disapprove}} -> false
            {:fail, %{on_fail: :refer}} -> false
            _ -> true
          end) and auto_approvable

        # {approved, disapproved, referred} |> IO.inspect(label: "exercise status {approve, disapprove, referred}")

        case {approved, disapproved, referred} do
          {_,    _,     true } -> Submission.refer(s)
          {_,    true,  false} -> Submission.disapprove(s)
          {true, false, false} -> Submission.approve(s)
          _truth_table  -> s
        end
      end

      defp append_analysis_failure(s = %Submission{}, {line, error, token}) do
        comment_params = %{line: line, error: "#{error}#{token}"}

        Submission.append_comment(s, {Constants.general_parsing_error, comment_params})
      end
    end
  end

  def compile_feature({feature_data, feature_forms}, code_ast) do
    name = Keyword.fetch!(feature_data, :name)
    comment = Keyword.fetch!(feature_data, :comment)
    status = Keyword.get(feature_data, :status, :test)
    on_fail = Keyword.get(feature_data, :on_fail, :disapprove)
    find_type = Keyword.get(feature_data, :find, :all)
    find_at_depth = Keyword.get(feature_data, :depth, nil)
    suppress_if = Keyword.get(feature_data, :suppress_if, false)


    form_expr =
      feature_forms
      |> Enum.map(&compile_form(&1, find_at_depth, code_ast))
      |> Enum.reduce(:start, &combine_compiled_forms(find_type, &1, &2))
      |> handle_combined_compiled_forms(find_type)

    case status do
      :test ->
        quote do
          test_description = %{
            name: unquote(name),
            comment: unquote(comment),
            status: unquote(status),
            on_fail: unquote(on_fail),
            suppress_if: unquote(suppress_if),
          }

          if unquote(form_expr) do
            {:pass, test_description}
          else

            {:fail, test_description}
          end
        end

      :skip ->
        quote do
          {:skip, test_description}
        end
    end
  end

  def compile_form(form, find_at_depth, code_ast) do
    find_ast_string = Keyword.fetch!(form, :find_ast_string)
    block_params = Keyword.fetch!(form, :block_params)

    find_ast = Code.string_to_quoted!(find_ast_string)

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

          cond do
            finding_depth and is_list(params) ->
              found =
                params
                |> Enum.chunk_every(unquote(block_params), 1, :discard)
                |> Enum.reduce(false, fn
                  chunk, false ->
                    match?(unquote(find_ast), chunk)

                  _chunk, true ->
                    true
                end)

              {node, found}

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

  defp get_compile_form_prewalk_fn(false, find_ast, find_at_depth) do
    quote do
      fn
        node, false, depth ->
          # IO.inspect({node, depth, inspect(unquote(Macro.escape(find_ast))), unquote(find_at_depth)}, label: ">>>")

          finding_depth = unquote(find_at_depth) in [nil, depth]

          cond do
            finding_depth ->
              {node, match?(unquote(find_ast), node)} #|> IO.inspect(label: "298")

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

  def handle_combined_compiled_forms(combined_expr, find_type) do
    case find_type do
      type when type in [:all, :any] -> combined_expr
      type when type in [:none] -> quote do: unquote(combined_expr) == 0
      type when type in [:one] -> quote do: unquote(combined_expr) == 1
    end
  end
end
