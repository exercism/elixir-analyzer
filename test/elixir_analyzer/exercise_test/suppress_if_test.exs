# credo:disable-for-this-file Credo.Check.Warning.IoInspect

defmodule ElixirAnalyzer.ExerciseTest.SuppressIfTest do
  alias ElixirAnalyzer.Constants

  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.Support.AnalyzerVerification.SuppressIf

  test_exercise_analysis "common check is found and suppresses assert/feature/check 1",
    comments: [Constants.solution_debug_functions()] do
    defmodule MyModule do
      def my_function() do
        foo()
        |> IO.inspect()
      end
    end
  end

  test_exercise_analysis "assert 1 and feature 1 find foo",
    comments: [
      "feature 1: foo() was called",
      "assert 1: foo() was called",
      "check source 1: foo() was called"
    ] do
    defmodule MyModule do
      def my_function() do
        foo()
      end
    end
  end

  test_exercise_analysis "assert/feature/check 1 find foo and suppress assert/feature/check 2",
    comments: [
      "feature 1: foo() was called",
      "assert 1: foo() was called",
      "check source 1: foo() was called"
    ] do
    defmodule MyModule do
      def my_function() do
        foo()
        bar()
      end
    end
  end

  test_exercise_analysis "assert/feature/check 2 find bar",
    comments: [
      "feature 2: bar() was called",
      "assert 2: bar() was called",
      "check source 2: bar() was called"
    ] do
    defmodule MyModule do
      def my_function() do
        bar()
      end
    end
  end

  test_exercise_analysis "assert/feature/check 1 find foo and suppress assert/feature/check 3",
    comments: [
      "feature 1: foo() was called",
      "assert 1: foo() was called",
      "check source 1: foo() was called"
    ] do
    defmodule MyModule do
      def my_function() do
        foo()
        baz()
      end
    end
  end

  test_exercise_analysis "assert/feature/check 3 find baz",
    comments: [
      "feature 3: baz() was called",
      "assert 3: baz() was called",
      "check source 3: baz() was called"
    ] do
    defmodule MyModule do
      def my_function() do
        baz()
      end
    end
  end

  test_exercise_analysis "assert/feature/check 4 find qux",
    comments: [
      "feature 4: qux() was called",
      "assert 4: qux() was called",
      "check source 4: qux() was called"
    ] do
    defmodule MyModule do
      def my_function() do
        qux()
      end
    end
  end

  test_exercise_analysis "feature 2 finds bar and suppress assert/feature/check 4 find qux",
    comments_include: [
      "feature 2: bar() was called"
    ],
    comments_exclude: [
      "feature 4: qux() was called",
      "assert 4: qux() was called",
      "check source 4: qux() was called"
    ] do
    defmodule MyModule do
      def my_function() do
        bar()
        qux()
      end
    end
  end

  test_exercise_analysis "feature 3 finds baz and suppress assert/feature/check 4 find qux",
    comments_include: [
      "feature 3: baz() was called"
    ],
    comments_exclude: [
      "feature 4: qux() was called",
      "assert 4: qux() was called",
      "check source 4: qux() was called"
    ] do
    defmodule MyModule do
      def my_function() do
        baz()
        qux()
      end
    end
  end

  test_exercise_analysis "feature 2/3 finds bar/baz and suppress assert/feature/check 4 find qux",
    comments_include: [
      "feature 2: bar() was called",
      "feature 3: baz() was called"
    ],
    comments_exclude: [
      "feature 4: qux() was called",
      "assert 4: qux() was called",
      "check source 4: qux() was called"
    ] do
    defmodule MyModule do
      def my_function() do
        bar()
        baz()
        qux()
      end
    end
  end

  describe "Error is triggered when wrong arguments are passed to suppress_if" do
    @suppress_if_error "Invalid :suppress_if arguments. Arguments must have the form\n  suppress_if \"some check name\", (:pass | :fail)\n"
    test "works with assert_call" do
      assert_raise RuntimeError, @suppress_if_error, fn ->
        defmodule SuppressIf do
          use ElixirAnalyzer.ExerciseTest

          assert_call "assert_call" do
            suppress_if "some other check"
            called_fn module: Keyword, name: :get_values
          end
        end
      end
    end

    test "works with feature" do
      assert_raise RuntimeError, @suppress_if_error, fn ->
        defmodule SuppressIf do
          use ElixirAnalyzer.ExerciseTest

          feature "feature" do
            suppress_if {"some other check", :fail}

            form do
              _ignore
            end
          end
        end
      end
    end

    test "works with check_source" do
      assert_raise RuntimeError, @suppress_if_error, fn ->
        defmodule SuppressIf do
          use ElixirAnalyzer.ExerciseTest

          check_source "check_source" do
            suppress_if "some other check", false

            check(_source) do
              true
            end
          end
        end
      end
    end
  end
end
