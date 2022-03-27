defmodule ElixirAnalyzer.ExerciseTest.Feature do
  @moduledoc """
  Defines a `feature` macro that allows looking for specific snippets
  whose AST matches part of the AST of the solution.
  """

  alias ElixirAnalyzer.Comment
  alias ElixirAnalyzer.ExerciseTest.Feature.FeatureError

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
      forms: []
    }

    :ok = validate_feature_block(block)
    {_, feature_data} = Macro.prewalk(block, feature_data, &gather_feature_data/2)

    # Check if feature forms are unique
    feature_data.forms
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.sort()
    |> then(fn forms -> [forms, tl(forms)] end)
    |> Enum.zip_with(fn
      [{form, i}, {form, j}] ->
        raise FeatureError,
          message:
            "Forms number #{min(i, j)} and #{max(i, j)} of \"#{description}\" compile to the same value."

      _ ->
        :ok
    end)

    # made into a key-val list for better quoting
    feature_forms = Enum.sort(feature_data.forms)
    feature_data = Map.delete(feature_data, :forms)
    feature_data = Map.to_list(feature_data)

    unless Keyword.has_key?(feature_data, :comment) do
      raise "Comment must be defined for each feature test"
    end

    quote do
      # Check if the feature is unique
      case Enum.filter(@feature_tests, fn {data, forms} ->
             {Keyword.get(data, :find), Keyword.get(data, :depth), forms} ==
               {Keyword.get(unquote(feature_data), :find),
                Keyword.get(unquote(feature_data), :depth), unquote(Macro.escape(feature_forms))}
           end) do
        [{data, _forms} | _] ->
          raise FeatureError,
            message:
              "Features \"#{data[:name]}\" and \"#{unquote(description)}\" compile to the same value."

        _ ->
          @feature_tests [
            {unquote(feature_data), unquote(Macro.escape(feature_forms))} | @feature_tests
          ]
      end
    end
  end

  @supported_expressions [:comment, :type, :find, :suppress_if, :depth, :form]
  defp validate_feature_block({:__block__, _, args}) do
    Enum.each(args, fn {name, _, _} ->
      if name not in @supported_expressions do
        raise """
        Unsupported expression `#{name}`.
        The macro `feature` supports expressions: #{Enum.join(@supported_expressions, ", ")}.
        """
      end
    end)

    :ok
  end

  defp gather_feature_data({:type, _, [type]} = node, acc) do
    if not Comment.supported_type?(type) do
      raise """
      Unsupported type `#{type}`.
      The macro `feature` supports the following types: #{Enum.join(Comment.supported_types(), ", ")}.
      """
    end

    {node, put_in(acc, [:type], type)}
  end

  defp gather_feature_data({field, _, [f]} = node, acc)
       when field in [:comment, :find] do
    {node, put_in(acc, [field], f)}
  end

  defp gather_feature_data({:suppress_if, _, args} = node, acc) do
    case args do
      [name, condition] when condition in [:pass, :fail] ->
        {node, put_in(acc, [:suppress_if], {name, condition})}

      _ ->
        raise """
        Invalid :suppress_if arguments. Arguments must have the form
          suppress_if "some check name", (:pass | :fail)
        """
    end
  end

  defp gather_feature_data({:depth, _, [f]} = node, acc) when is_integer(f) do
    {node, put_in(acc, [:depth], f)}
  end

  defp gather_feature_data({:form, _, [[do: form]]} = node, acc) do
    ast =
      Macro.prewalk(form, fn
        {name, _, param} -> {name, [:_ignore], param}
        node -> node
      end)

    {ast, block_params} =
      case ast do
        {:__block__, _, [param]} ->
          {param, false}

        {:__block__, _, [_ | _] = params} ->
          {params, length(params)}

        _ ->
          {ast, false}
      end

    {node,
     update_in(acc, [:forms], fn fs ->
       [[{:find_ast, ast}, {:block_params, block_params}] | fs]
     end)}
  end

  defp gather_feature_data(node, acc), do: {node, acc}
end
