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
        defmodule Factorial_module do
        end
      end

    assert ModulePascalCase.run(code) == [
             {:fail,
              %Comment{
                type: :actionable,
                comment: Constants.solution_module_pascal_case(),
                params: %{
                  expected: "FactorialModule",
                  actual: "Factorial_module"
                }
              }}
           ]
  end

  test "only reports the first module name" do
    code =
      quote do
        defmodule Factorial_module do
          defmodule Factorial_submodule do
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
                  expected: "FactorialModule",
                  actual: "Factorial_module"
                }
              }}
           ]
  end

  test "reports the inner module name" do
    code =
      quote do
        defmodule Factorial do
          defmodule Factorial_submodule do
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
                  actual: "Factorial_submodule"
                }
              }}
           ]
  end

  test "reports a module name with many segments" do
    code =
      quote do
        defmodule MyLibrary.Math_ops.Factorial do
        end
      end

    assert ModulePascalCase.run(code) == [
             {:fail,
              %Comment{
                type: :actionable,
                comment: Constants.solution_module_pascal_case(),
                params: %{
                  expected: "MyLibrary.MathOps.Factorial",
                  actual: "MyLibrary.Math_ops.Factorial"
                }
              }}
           ]
  end

  test "reports an inner module name with many segments" do
    code =
      quote do
        defmodule MyLibrary do
          defmodule Math_ops.Factorial do
          end
        end
      end

    assert ModulePascalCase.run(code) == [
             {:fail,
              %Comment{
                type: :actionable,
                comment: Constants.solution_module_pascal_case(),
                params: %{
                  expected: "MathOps.Factorial",
                  actual: "Math_ops.Factorial"
                }
              }}
           ]
  end
end
