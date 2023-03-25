defmodule ElixirAnalyzer.ExerciseTest.CheckSource.Compiler do
  @moduledoc false

  alias ElixirAnalyzer.Comment
  alias ElixirAnalyzer.Source

  def compile({check_source_data, check_function}, code_source) do
    name = Keyword.fetch!(check_source_data, :description)
    comment = Keyword.fetch!(check_source_data, :comment)
    type = Keyword.get(check_source_data, :type, :informative)
    suppress_if = Keyword.get(check_source_data, :suppress_if, [])

    test_description =
      Macro.escape(%Comment{
        name: name,
        comment: comment,
        type: type,
        suppress_if: suppress_if
      })

    quote do
      (fn %Source{} = source ->
         case unquote(check_function).(source) do
           true ->
             {:pass, unquote(test_description)}

           false ->
             {:fail, unquote(test_description)}

           {true, params} when is_map(params) ->
             {:pass, %{unquote(test_description) | params: params}}

           {false, params} when is_map(params) ->
             {:fail, %{unquote(test_description) | params: params}}

           _ ->
             raise "check must be a boolean or a tuple with a boolean and a map of parameters for the comment"
         end
       end).(unquote(code_source))
    end
  end
end
