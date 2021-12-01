defmodule ElixirAnalyzer.ExerciseTest.CheckSource do
  @moduledoc """
  Defines a `check_source` macro that allows checking the source code
  """

  alias ElixirAnalyzer.Comment

  @doc false
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)

      @check_source_tests []
    end
  end

  @doc """
  Defines a macro which runs a boolean function on the source code.

  This macro then collates the block into a map structure resembling:
  test_data = %{
    description: description,
    type: :actionable,
    comment: "message",
    suppress_if: {"name of other test", :fail}
  }
  and an AST for the function
  """
  defmacro check_source(description, do: block) do
    :ok = validate_check_block(block)

    test_data =
      block
      |> walk_check_source_block()
      |> Map.put(:description, description)
      |> Map.put_new(:type, :informative)

    check = test_data.check

    test_data =
      test_data
      |> Map.delete(:check)
      # made into a key-val list for better quoting
      |> Map.to_list()

    unless Keyword.has_key?(test_data, :comment) do
      raise "Comment must be defined for each check_source test"
    end

    quote do
      @check_source_tests [
        {unquote(test_data), unquote(Macro.escape(check))} | @check_source_tests
      ]
    end
  end

  @supported_expressions [:comment, :type, :suppress_if, :check]
  defp validate_check_block({:__block__, _, args}) do
    Enum.each(args, fn {name, _, _} ->
      if name not in @supported_expressions do
        raise """
        Unsupported expression `#{name}`.
        The macro `check_source` supports expressions: #{Enum.join(@supported_expressions, ", ")}.
        """
      end
    end)
  end

  defp walk_check_source_block(block, test_data \\ %{}) do
    {_, test_data} = Macro.prewalk(block, test_data, &do_walk_check_source_block/2)
    test_data
  end

  defp do_walk_check_source_block({:comment, _, [comment]} = node, test_data) do
    {node, Map.put(test_data, :comment, comment)}
  end

  defp do_walk_check_source_block({:type, _, [type]} = node, test_data) do
    if not Comment.supported_type?(type) do
      raise """
      Unsupported type `#{type}`.
      The macro `check_source` supports the following types: #{Enum.join(Comment.supported_types(), ", ")}.
      """
    end

    {node, Map.put(test_data, :type, type)}
  end

  defp do_walk_check_source_block({:suppress_if, _, args} = node, test_data) do
    case args do
      [name, condition] when condition in [:pass, :fail] ->
        {node, Map.put(test_data, :suppress_if, {name, condition})}

      _ ->
        raise """
        Invalid :suppress_if arguments. Arguments must have the form
          suppress_if "some check name", (:pass | :fail)
        """
    end
  end

  defp do_walk_check_source_block({:check, _, [source, [do: function]]} = node, test_data) do
    function = {:fn, [], [{:->, [], [[source], function]}]}

    {node, Map.put(test_data, :check, function)}
  end

  defp do_walk_check_source_block(node, test_data) do
    {node, test_data}
  end
end
