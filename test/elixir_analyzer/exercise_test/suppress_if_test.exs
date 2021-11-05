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
end
