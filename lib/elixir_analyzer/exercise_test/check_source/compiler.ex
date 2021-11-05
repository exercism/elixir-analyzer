defmodule ElixirAnalyzer.ExerciseTest.CheckSource.Compiler do
  @moduledoc false

  alias ElixirAnalyzer.Comment

  def compile({check_source_data, check_function}, code_string) do
    name = Keyword.fetch!(check_source_data, :description)
    comment = Keyword.fetch!(check_source_data, :comment)
    type = Keyword.get(check_source_data, :type, :informative)
    suppress_if = Keyword.get(check_source_data, :suppress_if, false)

    test_description =
      Macro.escape(%Comment{
        name: name,
        comment: comment,
        type: type,
        suppress_if: suppress_if
      })

    quote do
      (fn string ->
         if unquote(check_function).(string) do
           {:pass, unquote(test_description)}
         else
           {:fail, unquote(test_description)}
         end
       end).(unquote(code_string))
    end
  end
end
