# credo:disable-for-this-file Credo.Check.Readability.ModuleAttributeNames
# credo:disable-for-this-file Credo.Check.Readability.FunctionNames
# credo:disable-for-this-file Credo.Check.Readability.VariableNames
# credo:disable-for-this-file Credo.Check.Readability.ModuleNames
# credo:disable-for-this-file Credo.Check.Warning.IoInspect

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
        defmodule MyModule do
          def f(some_variable) do
            another_variable = [some_variable]
          end
        end,
        defmodule MyModule do
          a = 1
          b = 2
          {var_one, var_two} = {a, b}
          [b, var_two | var_one]
        end,
        defmodule MyModule do
          "hi " <> first_name = polite_morning_greeting
          %{first_name: first_name}
        end,
        defmodule MyModule do
          def fun(some_value), do: ^some_value == nil
        end
      ]
    end

    test_exercise_analysis "reports non snake_case variable names",
      comments_include: [Constants.solution_variable_name_snake_case()] do
      [
        defmodule MyModule do
          def f(someVariable) do
            another_variable = [someVariable]
          end
        end,
        defmodule MyModule do
          a = 1
          b = 2
          {var_one, varTwwo} = {a, b}
          [b, varTwwo | var_one]
        end,
        defmodule MyModule do
          "hi " <> first_name = polite_morningGreeting
          %{first_name: first_name}
        end,
        defmodule MyModule do
          def fun(some_value), do: ^someValue == nil
        end
      ]
    end
  end

  describe "debugging functions" do
    test_exercise_analysis "reports IO.inspect",
      comments: [Constants.solution_debug_functions()] do
      [
        defmodule MyModule do
          def foo() do
            (1 + 1)
            |> IO.inspect()
          end
        end,
        defmodule MyModule do
          alias IO, as: Debug

          def foo(name) do
            Debug.inspect(name)
          end
        end,
        defmodule MyModule do
          import IO

          def foo(name) do
            inspect(name)
          end
        end,
        defmodule MyModule do
          import IO, only: [inspect: 1]

          def foo(name) do
            inspect(name)
          end
        end
      ]
    end

    test_exercise_analysis "reports Kernel.dbg",
      comments: [Constants.solution_debug_functions()] do
      [
        defmodule MyModule do
          def foo() do
            (1 + 1)
            |> dbg()
          end
        end,
        defmodule MyModule do
          alias Kernel, as: Debug

          def foo(name) do
            Debug.dbg(name)
          end
        end
      ]
    end
  end

  describe "boilerplate and TODO comments" do
    test_exercise_analysis "reports both",
      comments: [Constants.solution_boilerplate_comment(), Constants.solution_todo_comment()] do
      [
        ~S"""
        defmodule Lasagna do
          # Please define the 'expected_minutes_in_oven/0' function
            def expected_minutes_in_oven() do
          40
          end

          # Please define the 'alarm/0' function
          def alarm() do
            "Ding!"
          end

          # TODO: remove all of those boilerplate comments!
        end
        """
      ]
    end
  end

  describe "boolean functions" do
    test_exercise_analysis "reports function with wrong name",
      comments: [Constants.solution_def_with_is()] do
      [
        defmodule MyModule do
          def is_active_user?(user), do: user.active
        end,
        defmodule MyModule do
          defp is_active_user?(user), do: user.active
        end,
        defmodule MyModule do
          def is_active_user(user), do: user.active
        end,
        defmodule MyModule do
          defp is_active_user(user), do: user.active
        end
      ]
    end

    test_exercise_analysis "reports guard with wrong name",
      comments: [Constants.solution_defguard_with_question_mark()] do
      [
        defmodule MyModule do
          defguard(is_active_user?(user), do: true)
        end,
        defmodule MyModule do
          defguardp(is_active_user?(user), do: true)
        end,
        defmodule MyModule do
          defguard(active_user?(user), do: true)
        end,
        defmodule MyModule do
          defguardp(active_user?(user), do: true)
        end
      ]
    end

    test_exercise_analysis "reports macro with wrong name",
      comments: [Constants.solution_defmacro_with_is_and_question_mark()] do
      [
        defmodule MyModule do
          defmacro is_active_user?(user), do: user.active
        end,
        defmodule MyModule do
          defmacrop is_active_user?(user), do: user.active
        end
      ]
    end
  end

  describe "function capture" do
    test_exercise_analysis "reports creating anonymous function rather then function capture",
      comments: [Constants.solution_use_function_capture()] do
      [
        defmodule MyModule do
          def do_nothing(list), do: Enum.map(list, fn x -> Function.identity(x) end)
        end,
        defmodule MyModule do
          def do_nothing(list), do: Enum.map(list, &Function.identity(&1))
        end
      ]
    end
  end

  describe "deprecated Erlang :random module" do
    test_exercise_analysis "reports using any of the :random functions",
      comments: [Constants.solution_deprecated_random_module()] do
      [
        defmodule Lottery do
          def draw(), do: :random.uniform()
        end,
        defmodule Lottery do
          def cheat(), do: :random.seed({1, 2, 3})
        end
      ]
    end

    test_exercise_analysis "doesn't report using modern :rand",
      comments: [] do
      [
        defmodule Lottery do
          def draw(), do: :rand.uniform()
        end,
        defmodule Lottery do
          def cheat(), do: :rand.seed(:default, {1, 2, 3})
        end
      ]
    end
  end
end
