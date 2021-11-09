defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.FunctionCapture do
  @moduledoc """
  Check if anonymous functions are used where function capture can be used instead
  """

  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Comment

  @spec run(Macro.t()) :: [{:pass | :fail | :skip, %Comment{}}]
  def run(code_ast) do
    {_, functions} =
      Macro.prewalk(code_ast, [], fn ast, functions -> traverse(ast, functions) end)

    case functions |> Enum.map(&format_function(&1)) |> Enum.reverse() do
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

  @exceptions [:<<>>, :{}]
  defp traverse({:&, _, [{name, _, args}]} = node, functions) when name not in @exceptions do
    wrong_use? =
      args
      |> Enum.with_index(1)
      |> Enum.all?(&match?({{:&, _, [index]}, index}, &1))

    if wrong_use? and actual_function?(name) do
      {node, [{:&, name, length(args)} | functions]}
    else
      {node, functions}
    end
  end

  defp traverse({:fn, _, [{:->, _, [args, {name, _, args}]}]} = node, functions)
       when name not in @exceptions do
    args = Enum.map(args, fn {var, _, _} -> var end)

    if actual_function?(name) do
      {node, [{:fn, name, args} | functions]}
    else
      {node, functions}
    end
  end

  defp traverse(node, functions) do
    {node, functions}
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

  defp format_function({:fn, name, args}) do
    name = format_function_name(name)
    correct = "&#{name}/#{length(args)}"
    args = Enum.join(args, ", ")
    wrong = "fn #{args} -> #{name}(#{args}) end"
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
