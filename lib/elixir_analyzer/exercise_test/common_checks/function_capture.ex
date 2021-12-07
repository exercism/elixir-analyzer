defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.FunctionCapture do
  @moduledoc """
  Check if anonymous functions are used where function capture can be used instead
  """

  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Comment

  @spec run(Macro.t()) :: [{:pass | :fail | :skip, Comment.t()}]
  def run(code_ast) do
    acc = %{capture_depth: 0, functions: []}

    {_, %{functions: functions}} =
      Macro.traverse(code_ast, acc, &annotate(&1, &2), fn ast, acc ->
        find_anonymous(ast, acc)
      end)

    case functions |> Enum.map(&format_function/1) |> Enum.reverse() do
      [] ->
        []

      [{wrong_function, correct_function} | _] ->
        [
          {:fail,
           %Comment{
             type: :informative,
             name: Constants.solution_use_function_capture(),
             comment: Constants.solution_use_function_capture(),
             params: %{
               expected: correct_function,
               actual: wrong_function
             }
           }}
        ]
    end
  end

  defp annotate({:&, _, [{_name, _, _args}]} = node, %{capture_depth: depth} = acc) do
    {node, %{acc | capture_depth: depth + 1}}
  end

  defp annotate(node, acc), do: {node, acc}

  @exceptions [:<<>>, :{}]
  defp find_anonymous(
         {:&, _, [{name, _, args}]} = node,
         %{capture_depth: depth, functions: functions}
       ) do
    wrong_use? =
      args
      |> Enum.with_index(1)
      |> Enum.all?(&match?({{:&, _, [index]}, index}, &1))

    depth = depth - 1

    functions =
      if depth == 0 and wrong_use? and actual_function?(name) and name not in @exceptions do
        [{:&, name, length(args)} | functions]
      else
        functions
      end

    {node, %{capture_depth: depth - 1, functions: functions}}
  end

  # fn -> foo end
  defp find_anonymous(
         {:fn, _, [{:->, _, [[], {name, _, atom}]}]} = node,
         %{capture_depth: 0, functions: functions} = acc
       )
       when is_atom(atom) do
    {node, %{acc | functions: [{:fn, name, nil} | functions]}}
  end

  defp find_anonymous(
         {:fn, _, [{:->, _, [args, {name, _, args}]}]} = node,
         %{capture_depth: 0, functions: functions} = acc
       )
       when name not in @exceptions do
    args = Enum.map(args, fn {var, _, _} -> var end)

    if actual_function?(name) do
      {node, %{acc | functions: [{:fn, name, args} | functions]}}
    else
      {node, acc}
    end
  end

  defp find_anonymous(node, acc) do
    {node, acc}
  end

  defp actual_function?(name) when is_atom(name), do: true

  defp actual_function?({:., _, [{:__aliases__, _, _module_path}, name]}) when is_atom(name) do
    true
  end

  defp actual_function?({:., _, [module, name]}) when is_atom(module) and is_atom(name) do
    true
  end

  # motivation for this check: fn string -> unquote(parser).(string) end
  defp actual_function?(_), do: false

  defp format_function({:&, name, arity}) do
    name = format_function_name(name)
    correct = "&#{name}/#{arity}"
    args = Enum.map_join(1..arity, ", ", fn n -> "&#{n}" end)
    wrong = "&#{name}(#{args})"
    {wrong, correct}
  end

  defp format_function({:fn, name, nil}) do
    correct = "&#{name}/0"
    wrong = "fn -> #{name} end"
    {wrong, correct}
  end

  defp format_function({:fn, name, args}) do
    name = format_function_name(name)
    correct = "&#{name}/#{length(args)}"
    space = if Enum.empty?(args), do: "", else: " "
    args = Enum.join(args, ", ")
    wrong = "fn #{args}#{space}-> #{name}(#{args}) end"
    {wrong, correct}
  end

  defp format_function_name(name) when is_atom(name), do: name

  defp format_function_name({:., _, [{:__aliases__, _, module_path}, name]}) do
    "#{Enum.map_join(module_path, ".", &to_string/1)}.#{name}"
  end

  # Erlang functions
  defp format_function_name({:., _, [module, name]}) do
    ":#{module}.#{name}"
  end
end
