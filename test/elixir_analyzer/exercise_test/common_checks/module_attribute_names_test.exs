# credo:disable-for-this-file Credo.Check.Readability.ModuleAttributeNames

defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.ModuleAttributeNamesTest do
  use ExUnit.Case
  alias ElixirAnalyzer.Comment
  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.ExerciseTest.CommonChecks.ModuleAttributeNames

  test "returns empty list if there are no module attributes" do
    code =
      quote do
        defmodule Factorial do
          def calculate(1), do: 1

          def calculate(n) do
            n * calculate(n - 1)
          end
        end
      end

    assert ModuleAttributeNames.run(code) == []
  end

  test "returns empty list if there are no module attributes with camelCase names" do
    code =
      quote do
        defmodule Factorial do
          @initial_value 1
          @spec calculate(integer) :: integer
          def calculate(1), do: @initial_value

          def calculate(n) do
            n * calculate(n - 1)
          end
        end
      end

    assert ModuleAttributeNames.run(code) == []
  end

  test "returns an actionable comment with params" do
    code =
      quote do
        defmodule Factorial do
          @initialValue 1
          @spec calculate(integer) :: integer
          def calculate(1), do: @initialValue

          def calculate(n) do
            n * calculate(n - 1)
          end
        end
      end

    assert ModuleAttributeNames.run(code) == [
             {:fail,
              %Comment{
                type: :actionable,
                name: Constants.solution_module_attribute_name_snake_case(),
                comment: Constants.solution_module_attribute_name_snake_case(),
                params: %{
                  expected: "initial_value",
                  actual: "initialValue"
                }
              }}
           ]
  end

  test "only reports the first module attribute" do
    code =
      quote do
        defmodule Factorial do
          @somethingElseCamelCase
          @initialValue 1
          @spec calculate(integer) :: integer
          def calculate(1), do: @initialValue

          def calculate(n) do
            n * calculate(n - 1)
          end
        end
      end

    assert ModuleAttributeNames.run(code) == [
             {:fail,
              %Comment{
                type: :actionable,
                name: Constants.solution_module_attribute_name_snake_case(),
                comment: Constants.solution_module_attribute_name_snake_case(),
                params: %{
                  expected: "something_else_camel_case",
                  actual: "somethingElseCamelCase"
                }
              }}
           ]
  end
end
