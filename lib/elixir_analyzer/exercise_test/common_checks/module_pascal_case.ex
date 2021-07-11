defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.ModulePascalCase do
  @moduledoc """
  Report the first defined module names that is not in PascalCase 

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
      correct_name = Enum.map_join(wrong_name, ".", fn n -> n |> to_string |> to_pascal_case end)
      wrong_name = Enum.map_join(wrong_name, ".", &to_string/1)

      [
        {:fail,
         %Comment{
           type: :actionable,
           comment: Constants.solution_module_pascal_case(),
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

  defp traverse({:defmodule, _meta, [{:__aliases__, _meta2, names}, _do]} = ast, wrong_names) do
    if Enum.all?(names, &pascal_case?/1) do
      {ast, wrong_names}
    else
      {ast, [names | wrong_names]}
    end
  end

  defp traverse(ast, names) do
    {ast, names}
  end

  defp pascal_case?(name) do
    # the code had to compile and pass all the tests to get to the analyzer
    # so we can assume the name is otherwise valid
    to_pascal_case(name) == to_string(name)
  end

  defp to_pascal_case(name) do
    # Macro.camelize is good enough because a module attribute name must be a valid Elixir identifier anyway
    Macro.camelize(to_string(name))
  end
end
