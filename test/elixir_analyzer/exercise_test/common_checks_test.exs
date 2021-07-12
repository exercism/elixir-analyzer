# credo:disable-for-this-file Credo.Check.Readability.ModuleAttributeNames
# credo:disable-for-this-file Credo.Check.Readability.FunctionNames
# credo:disable-for-this-file Credo.Check.Readability.VariableNames
# credo:disable-for-this-file Credo.Check.Readability.ModuleNames

defmodule ElixirAnalyzer.ExerciseTestTest.Empty do
  use ElixirAnalyzer.ExerciseTest
end

defmodule ElixirAnalyzer.ExerciseTest.CommonChecksTest do
  alias ElixirConstants.Constants

  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.ExerciseTestTest.Empty

  describe "function, guard, macro names" do
    test_exercise_analysis "doesn't report correct names",
      comments_exclude: [Constants.solution_function_name_snake_case()] do
      [
        defmodule SomeModule do
          def foo_bar, do: 1

          def foo_bar_baz do
            foo_bar + 8
          end
        end,
        defmodule SomeModule do
          defp foo_bar, do: 1

          defp foo_bar_baz do
            foo_bar + 8
          end
        end,
        defmodule SomeModule do
          defmacro foo_bar, do: 1

          defmacro foo_bar_baz do
            foo_bar + 8
          end
        end,
        defmodule SomeModule do
          defmacrop foo_bar, do: 1

          defmacrop foo_bar_baz do
            foo_bar + 8
          end
        end,
        defmodule SomeModule do
          defguard(foo_bar, do: 1)

          defguard foo_bar_baz do
            foo_bar + 8
          end
        end,
        defmodule SomeModule do
          defguardp(foo_bar, do: 1)

          defguardp foo_bar_baz do
            foo_bar + 8
          end
        end
      ]
    end

    test_exercise_analysis "reports incorrect names",
      comments_include: [Constants.solution_function_name_snake_case()] do
      [
        defmodule SomeModule do
          def fooBarBaz do
            foo_bar + 8
          end
        end,
        defmodule SomeModule do
          defp fooBarBaz do
            foo_bar + 8
          end
        end,
        defmodule SomeModule do
          defmacro fooBarBaz do
            foo_bar + 8
          end
        end,
        defmodule SomeModule do
          defmacrop fooBarBaz do
            foo_bar + 8
          end
        end,
        defmodule SomeModule do
          defguard fooBarBaz do
            foo_bar + 8
          end
        end,
        defmodule SomeModule do
          defguardp fooBarBaz do
            foo_bar + 8
          end
        end
      ]
    end
  end

  describe "module attribute names" do
    test_exercise_analysis "doesn't report correct module attribute names",
      comments_exclude: [Constants.solution_module_attribute_name_snake_case()] do
      [
        defmodule SomeModule do
          @foo_bar
        end,
        defmodule SomeModule do
          @foo_bar1
          @foo_bar2
        end,
        defmodule SomeModule do
          @foo_bar1 5
          @foo_bar2 2
        end
      ]
    end

    test_exercise_analysis "reports a module attribute that doesn't use snake_case",
      comments_include: [Constants.solution_module_attribute_name_snake_case()] do
      [
        defmodule SomeModule do
          @fooBar
        end,
        defmodule SomeModule do
          @someValue 3
        end
      ]
    end
  end

  describe "module names in PascalCase" do
    test_exercise_analysis "doesn't report correct module names",
      comments_exclude: [Constants.solution_module_pascal_case()] do
      [
        defmodule SomeModule do
          nil
        end,
        defmodule SomeModule do
          defmodule SomeSubModule do
          end
        end,
        defmodule SomeModule do
          defmodule SomeSubModule do
          end

          defmodule SomeOtherSubModule do
          end
        end,
        defmodule Some.Module do
          defmodule Some.Sub.Module do
          end
        end
      ]
    end

    test_exercise_analysis "reports a module attribute that doesn't use PascalCase",
      comments_include: [Constants.solution_module_pascal_case()] do
      [
        defmodule Some_module do
          nil
        end,
        defmodule SomeModule do
          defmodule Some_subModule do
          end
        end,
        defmodule SomeModule do
          defmodule SomeSubModule do
          end

          defmodule Some_otherSubModule do
          end
        end,
        defmodule Some.Sub_module do
        end,
        defmodule Some.Module do
          defmodule Some.Sub_module do
          end
        end
      ]
    end
  end

  describe "variable names" do
    test_exercise_analysis "doesn't report snake_case variable names",
      comments_exclude: [Constants.solution_variable_name_snake_case()] do
      [
        defmodule Module do
          def f(some_variable) do
            another_variable = [some_variable]
          end
        end,
        defmodule Module do
          a = 1
          b = 2
          {var_one, var_two} = {a, b}
          [b, var_two | var_one]
        end,
        defmodule Module do
          "hi " <> first_name = polite_morning_greeting
          %{first_name: first_name}
        end,
        defmodule Module do
          def fun(some_value), do: ^some_value == nil
        end
      ]
    end

    test_exercise_analysis "reports non snake_case variable names",
      comments_include: [Constants.solution_variable_name_snake_case()] do
      [
        defmodule Module do
          def f(someVariable) do
            another_variable = [someVariable]
          end
        end,
        defmodule Module do
          a = 1
          b = 2
          {var_one, varTwwo} = {a, b}
          [b, varTwwo | var_one]
        end,
        defmodule Module do
          "hi " <> first_name = polite_morningGreeting
          %{first_name: first_name}
        end,
        defmodule Module do
          def fun(some_value), do: ^someValue == nil
        end
      ]
    end
  end
end
