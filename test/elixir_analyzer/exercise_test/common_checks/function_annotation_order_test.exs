defmodule ElixirAnalyzer.Support.AnalyzerVerification.FunctionAnnotationOrder do
  use ElixirAnalyzer.ExerciseTest
end

defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.FunctionAnnotationOrderTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.Support.AnalyzerVerification.FunctionAnnotationOrder

  alias ElixirAnalyzer.Constants

  test_exercise_analysis "wrong order crashes",
    comments: [Constants.solution_function_annotation_order()] do
    defmodule Test do
      @spec x()
      @doc ""
      def x()
    end
  end

  test_exercise_analysis "works for def, defp, defmacro, defmacrop, defguard, and defguardp",
    comments: [Constants.solution_function_annotation_order()] do
    [
      defmodule Test do
        @spec x()
        @doc ""
        def x()
      end,
      defmodule Test do
        @spec x()
        @doc ""
        defp x()
      end,
      defmodule Test do
        @spec x()
        @doc ""
        defmacro x()
      end,
      defmodule Test do
        @spec x()
        @doc ""
        defmacrop x()
      end,
      defmodule Test do
        @spec x()
        @doc ""
        defguard x()
      end,
      defmodule Test do
        @spec x()
        @doc ""
        defguardp x()
      end
    ]
  end

  test_exercise_analysis "non related definitions will not fail",
    comments: [] do
    [
      defmodule Test do
        @doc ""
        def x

        @spec y
        def y
      end
    ]
  end

  test_exercise_analysis "another non related definition will not fail",
    comments: [] do
    [
      defmodule Test do
        @spec x
        def x

        @doc ""
        def y
      end
    ]
  end

  test_exercise_analysis "multiple functions before attributes will not fail",
    comments: [] do
    [
      defmodule Test do
        def a
        def b

        @doc ""
        @spec c
        def c
      end
    ]
  end

  test_exercise_analysis "function definition order does not impact order detection",
    comments: [Constants.solution_function_annotation_order()] do
    [
      defmodule Test do
        def a
        def b

        @spec c
        @doc ""
        def c
      end
    ]
  end

  test_exercise_analysis "other modules attributes will not make it crash",
    comments: [] do
    [
      defmodule Test do
        @const "Const"

        @doc ""
        @spec x
        def x

        @answer 42

        @doc ""
        @spec y
        def y
      end
    ]
  end

  test_exercise_analysis "function using when clause works",
    comments: [] do
    [
      defmodule Test do
        @spec empty?(list()) :: boolean()
        def empty?(list) when list == [], do: true
        def empty?(_), do: false
      end
    ]
  end

  test_exercise_analysis "@spec defined after function crashes",
    comments: [Constants.solution_function_annotation_order()] do
    defmodule Test do
      def empty?(list) when list == [], do: true
      @spec empty?(list()) :: boolean()
      def empty?(_), do: false
    end
  end

  test_exercise_analysis "one spec for multiple function works",
    comments: [] do
    [
      defmodule Test do
        @spec is_one(integer()) :: integer()
        def one?(1), do: true
        def one?(2), do: false
        def one?(3), do: false
        def one?(4), do: false
        def one?(_), do: false
      end
    ]
  end

  test_exercise_analysis "spec with parameter works",
    comments: [] do
    [
      defmodule Test do
        @spec is_one(number)
        def one?(number), do: number == 1
      end
    ]
  end

  test_exercise_analysis "@doc and @spec between two definitions crashes",
    comments: [Constants.solution_function_annotation_order()] do
    [
      defmodule Test do
        def a(x \\ [])
        @doc ""
        @spec a(list()) :: atom()
        def a([]), do: :empty
        def a(_), do: :full

        @spec b
        def b

        @spec c
        def c
      end,
      defmodule Test do
        @spec a
        def a

        def b(x \\ [])
        @doc ""
        @spec b(list()) :: atom()
        def b([]), do: :empty
        def b(_), do: :full

        @spec c
        def c
      end
    ]
  end

  test_exercise_analysis "returns a single error even if it checks multiple times",
    comments: [Constants.solution_function_annotation_order()] do
    [
      defmodule Test do
        @spec sum(number(), number()) :: number()
        @doc "sum two numbers"
        def sum(x, y), do: x + y

        @spec subtract(number(), number()) :: number()
        @doc "subtract two number"
        def subtract(x, y), do: x - y
      end
    ]
  end

  test_exercise_analysis "spec between function definitions crashes",
    comments: [Constants.solution_function_annotation_order()] do
    [
      defmodule Test do
        def test(x), do: x
        @spec test(any()) :: any()
        def test(x, y), do: x || y
      end
    ]
  end

  test_exercise_analysis "doc between function definitions fails",
    comments: [Constants.solution_function_annotation_order()] do
    [
      defmodule Test do
        def test(x), do: x
        @doc "just a test function"
        def test(x, y), do: x || y
      end
    ]
  end

  test_exercise_analysis "spec after function definitions fails",
    comments: [Constants.solution_function_annotation_order()] do
    [
      defmodule Test do
        def test(x), do: x
        @spec test(any()) :: any()
      end
    ]
  end

  test_exercise_analysis "doc after function definitions fails",
    comments: [Constants.solution_function_annotation_order()] do
    [
      defmodule Test do
        def test(x), do: x
        @doc "just a test function"
      end
    ]
  end

  test_exercise_analysis "sub-modules should not raise false positive error",
    comments: [] do
    [
      defmodule Test do
        def x(), do: 1

        defmodule Test.Y do
          @spec x() :: integer()
          def x(), do: 1
        end
      end,
      defmodule Test do
        alias Blah.Bluh
        def x(), do: 1

        defmodule Test.Y do
          @doc ""
          def x(), do: 1
        end
      end
    ]
  end
end
