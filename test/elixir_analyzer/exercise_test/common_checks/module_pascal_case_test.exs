# credo:disable-for-this-file Credo.Check.Readability.ModuleNames

defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.ModulePascalCaseTest do
  use ExUnit.Case
  alias ElixirAnalyzer.Comment
  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.ExerciseTest.CommonChecks.ModulePascalCase

  test "returns empty list if there are no module definition" do
    code =
      quote do
        def calculate(1), do: 1

        def calculate(n) do
          n * calculate(n - 1)
        end
      end

    assert ModulePascalCase.run(code) == []
  end

  test "returns empty list if there are no module names not in PascalCase" do
    code =
      quote do
        defmodule Factorial do
          defmodule FactorialSubmodule do
            defstruct :!
          end
        end
      end

    assert ModulePascalCase.run(code) == []
  end

  test "returns an actionable comment with params" do
    code =
      quote do
        defmodule factorial do
        end
      end

    assert ModulePascalCase.run(code) == [
             {:fail,
              %Comment{
                type: :actionable,
                comment: Constants.solution_module_pascal_case(),
                params: %{
                  expected: "Factorial",
                  actual: "factorial"
                }
              }}
           ]
  end

  test "only reports the first module name" do
    code =
      quote do
        defmodule factorial do
          defmodule factorial_submodule do
            defstruct :!
          end
        end
      end

    assert ModulePascalCase.run(code) == [
             {:fail,
              %Comment{
                type: :actionable,
                comment: Constants.solution_module_pascal_case(),
                params: %{
                  expected: "Factorial",
                  actual: "factorial"
                }
              }}
           ]
  end

  test "reports the inner module name" do
    code =
      quote do
        defmodule Factorial do
          defmodule factorial_submodule do
            defstruct :!
          end
        end
      end

    assert ModulePascalCase.run(code) == [
             {:fail,
              %Comment{
                type: :actionable,
                comment: Constants.solution_module_pascal_case(),
                params: %{
                  expected: "FactorialSubmodule",
                  actual: "factorial_submodule"
                }
              }}
           ]
  end
end
