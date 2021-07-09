# credo:disable-for-this-file Credo.Check.Readability.ModuleAttributeNames

defmodule ElixirAnalyzer.ExerciseTestTest.Empty do
  use ElixirAnalyzer.ExerciseTest
end

defmodule ElixirAnalyzer.ExerciseTest.CommonChecksTest do
  alias ElixirConstants.Constants

  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.ExerciseTestTest.Empty

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
end
