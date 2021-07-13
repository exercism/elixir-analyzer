defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.VariableNames do
  @moduledoc """
  Reports the first variable with a name that's not snake_case.

  Doesn't report more if there are more.
  A single comment should be enough for the student to know what to fix.

  Common check to be run on every single solution.
  """

  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Comment

  @spec run(Macro.t()) :: [{:pass | :fail | :skip, %Comment{}}]
  def run(ast) do
    {_, names} = Macro.prewalk(ast, [], &traverse/2)
    wrong_name = List.last(names)

    if wrong_name do
      wrong_name = to_string(wrong_name)
      correct_name = to_snake_case(wrong_name)

      [
        {:fail,
         %Comment{
           type: :actionable,
           comment: Constants.solution_variable_name_snake_case(),
           params: %{
             expected: correct_name,
             actual: wrong_name
           }
         }}
      ]
    else
      []
    end
  end

  @special_var_names [:__CALLER__, :__DIR__, :__ENV__, :__MODULE__, :__STACKTRACE__, :...]

  # "The third element is either a list of arguments for the function call or an atom. When this element is an atom, it means the tuple represents a variable."
  #   https://elixir-lang.org/getting-started/meta/quote-and-unquote.html
  defp traverse({name, _meta, module} = ast, names) when is_atom(module) do
    if snake_case?(name) or name in @special_var_names do
      {ast, names}
    else
      {ast, [name | names]}
    end
  end

  defp traverse(ast, names) do
    {ast, names}
  end

  defp snake_case?(name) do
    # the code had to compile and pass all the tests to get to the analyzer
    # so we can assume the name is otherwise valid
    to_snake_case(name) == to_string(name)
  end

  defp to_snake_case(name) do
    # Macro.underscore is good enough because a module attribute name must be a valid Elixir identifier anyway
    Macro.underscore(to_string(name))
  end
end
