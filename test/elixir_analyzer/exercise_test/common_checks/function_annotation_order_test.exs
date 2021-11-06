defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.FunctionAnnotationOrderTest do
  use ExUnit.Case
  alias ElixirAnalyzer.Comment
  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.ExerciseTest.CommonChecks.FunctionAnnotationOrder

  test "wrong order crashes" do
    ast =
      quote do
        defmodule Test do
          @spec x()
          @doc ""
          def x()
        end
      end

    assert FunctionAnnotationOrder.run(ast) == [
             {:fail,
              %Comment{
                type: :informative,
                name: Constants.solution_function_annotation_order(),
                comment: Constants.solution_function_annotation_order(),
                params: %{
                  expected: """
                  @doc
                  @spec x
                  def x
                  """,
                  actual: """
                  @spec x
                  @doc
                  def x
                  """
                }
              }}
           ]
  end

  test "works for def, defp, defmacro, defmacrop, defguard, and defguardp" do
    order_error = fn op, name ->
      [
        {:fail,
         %Comment{
           type: :informative,
           name: Constants.solution_function_annotation_order(),
           comment: Constants.solution_function_annotation_order(),
           params: %{
             expected: """
             @doc
             @spec #{name}
             #{op} #{name}
             """,
             actual: """
             @spec #{name}
             @doc
             #{op} #{name}
             """
           }
         }}
      ]
    end

    ast =
      quote do
        defmodule Test do
          @spec x()
          @doc ""
          def x()
        end
      end

    assert FunctionAnnotationOrder.run(ast) == order_error.("def", "x")

    ast =
      quote do
        defmodule Test do
          @spec x()
          @doc ""
          defp x()
        end
      end

    assert FunctionAnnotationOrder.run(ast) == order_error.("defp", "x")

    ast =
      quote do
        defmodule Test do
          @spec x()
          @doc ""
          defmacro x()
        end
      end

    assert FunctionAnnotationOrder.run(ast) == order_error.("defmacro", "x")

    ast =
      quote do
        defmodule Test do
          @spec x()
          @doc ""
          defmacrop x()
        end
      end

    assert FunctionAnnotationOrder.run(ast) == order_error.("defmacrop", "x")

    ast =
      quote do
        defmodule Test do
          @spec x()
          @doc ""
          defguard x()
        end
      end

    assert FunctionAnnotationOrder.run(ast) == order_error.("defguard", "x")

    ast =
      quote do
        defmodule Test do
          @spec x()
          @doc ""
          defguardp x()
        end
      end

    assert FunctionAnnotationOrder.run(ast) == order_error.("defguardp", "x")
  end

  test "non related definitions will not make crash" do
    ast =
      quote do
        defmodule Test do
          @doc ""
          def x

          @spec y
          def y
        end
      end

    assert FunctionAnnotationOrder.run(ast) == []
  end

  test "another non related definition will not make crash" do
    ast =
      quote do
        defmodule Test do
          @spec x
          def x

          @doc ""
          def y
        end
      end

    assert FunctionAnnotationOrder.run(ast) == []
  end

  test "multiple functions before attributes will not crash" do
    ast =
      quote do
        def a
        def b

        @doc ""
        @spec c
        def c
      end

    assert FunctionAnnotationOrder.run(ast) == []
  end

  test "function definition order doesnt impact" do
    ast =
      quote do
        defmodule Test do
          def a
          def b

          @spec c
          @doc ""
          def c
        end
      end

    assert FunctionAnnotationOrder.run(ast) == [
             {:fail,
              %Comment{
                type: :informative,
                name: Constants.solution_function_annotation_order(),
                comment: Constants.solution_function_annotation_order(),
                params: %{
                  expected: """
                  @doc
                  @spec c
                  def c
                  """,
                  actual: """
                  @spec c
                  @doc
                  def c
                  """
                }
              }}
           ]
  end

  test "other modules attributes will not make it crash" do
    ast =
      quote do
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
      end

    assert FunctionAnnotationOrder.run(ast) == []
  end

  test "function using when clause works" do
    ast =
      quote do
        defmodule Test do
          @spec empty?(list()) :: boolean()
          def empty?(list) when list == [], do: true
          def empty?(_), do: false
        end
      end

    assert FunctionAnnotationOrder.run(ast) == []
  end

  test "@spec defined after function crashes" do
    ast =
      quote do
        defmodule Test do
          def empty?(list) when list == [], do: true
          @spec empty?(list()) :: boolean()
          def empty?(_), do: false
        end
      end

    assert FunctionAnnotationOrder.run(ast) == [
             {:fail,
              %Comment{
                type: :informative,
                name: Constants.solution_function_annotation_order(),
                comment: Constants.solution_function_annotation_order(),
                params: %{
                  expected: """
                  @doc
                  @spec empty?
                  def empty?
                  """,
                  actual: """
                  @spec empty?
                  @doc
                  def empty?
                  """
                }
              }}
           ]
  end

  test "one spec for multiple function works" do
    ast =
      quote do
        @spec is_one(integer()) :: integer()
        def is_one(1), do: true
        def is_one(2), do: false
        def is_one(3), do: false
        def is_one(4), do: false
        def is_one(_), do: false
      end

    assert FunctionAnnotationOrder.run(ast) == []
  end

  test "spec with parameter works" do
    ast =
      quote do
        defmodule Test do
          @spec is_one(number)
          def is_one(number), do: number == 1
        end
      end

    assert FunctionAnnotationOrder.run(ast) == []
  end

  test "@doc and @spec between two definitions crashes" do
    ast =
      quote do
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
        end
      end

    assert FunctionAnnotationOrder.run(ast) == [
             {:fail,
              %Comment{
                type: :informative,
                name: Constants.solution_function_annotation_order(),
                comment: Constants.solution_function_annotation_order(),
                params: %{
                  expected: """
                  @doc
                  @spec a
                  def a
                  """,
                  actual: """
                  @spec a
                  @doc
                  def a
                  """
                }
              }}
           ]

    ast =
      quote do
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
      end

    assert FunctionAnnotationOrder.run(ast) == [
             {:fail,
              %Comment{
                type: :informative,
                name: Constants.solution_function_annotation_order(),
                comment: Constants.solution_function_annotation_order(),
                params: %{
                  expected: """
                  @doc
                  @spec b
                  def b
                  """,
                  actual: """
                  @spec b
                  @doc
                  def b
                  """
                }
              }}
           ]
  end

  test "returns multiple errors if it checks multiple times" do
    ast =
      quote do
        defmodule Test do
          @spec sum(number(), number()) :: number()
          @doc "sum two numbers"
          def sum(x, y), do: x + y

          @spec subtract(number(), number()) :: number()
          @doc "subtract two number"
          def subtract(x, y), do: x - y
        end
      end

    assert FunctionAnnotationOrder.run(ast) == [
             {:fail,
              %Comment{
                type: :informative,
                name: Constants.solution_function_annotation_order(),
                comment: Constants.solution_function_annotation_order(),
                params: %{
                  expected: """
                  @doc
                  @spec sum
                  def sum
                  """,
                  actual: """
                  @spec sum
                  @doc
                  def sum
                  """
                }
              }},
             {:fail,
              %Comment{
                type: :informative,
                name: Constants.solution_function_annotation_order(),
                comment: Constants.solution_function_annotation_order(),
                params: %{
                  expected: """
                  @doc
                  @spec subtract
                  def subtract
                  """,
                  actual: """
                  @spec subtract
                  @doc
                  def subtract
                  """
                }
              }}
           ]
  end

  test "spec between function definitions crashes" do
    ast =
      quote do
        defmodule Test do
          def test(x), do: x
          @spec test(any()) :: any()
          def test(x, y), do: x || y
        end
      end

    assert FunctionAnnotationOrder.run(ast) == [
             {:fail,
              %Comment{
                type: :informative,
                name: Constants.solution_function_annotation_order(),
                comment: Constants.solution_function_annotation_order(),
                params: %{
                  expected: """
                  @doc
                  @spec test
                  def test
                  """,
                  actual: """
                  @spec test
                  @doc
                  def test
                  """
                }
              }}
           ]
  end

  test "doc between function definitions crashes" do
    ast =
      quote do
        defmodule Test do
          def test(x), do: x
          @doc "just a test function"
          def test(x, y), do: x || y
        end
      end

    assert FunctionAnnotationOrder.run(ast) == [
             {:fail,
              %Comment{
                type: :informative,
                name: Constants.solution_function_annotation_order(),
                comment: Constants.solution_function_annotation_order(),
                params: %{
                  expected: """
                  @doc
                  @spec test
                  def test
                  """,
                  actual: """
                  @spec test
                  @doc
                  def test
                  """
                }
              }}
           ]
  end

  test "spec after function definitions crashes" do
    ast =
      quote do
        defmodule Test do
          def test(x), do: x
          @spec test(any()) :: any()
        end
      end

    assert FunctionAnnotationOrder.run(ast) == [
             {:fail,
              %Comment{
                type: :informative,
                name: Constants.solution_function_annotation_order(),
                comment: Constants.solution_function_annotation_order(),
                params: %{
                  expected: """
                  @doc
                  @spec test
                  def test
                  """,
                  actual: """
                  @spec test
                  @doc
                  def test
                  """
                }
              }}
           ]
  end

  test "doc after function definitions crashes" do
    ast =
      quote do
        defmodule Test do
          def test(x), do: x
          @doc "just a test function"
        end
      end

    assert FunctionAnnotationOrder.run(ast) == [
             {:fail,
              %Comment{
                type: :informative,
                name: Constants.solution_function_annotation_order(),
                comment: Constants.solution_function_annotation_order(),
                params: %{
                  expected: """
                  @doc
                  @spec test
                  def test
                  """,
                  actual: """
                  @spec test
                  @doc
                  def test
                  """
                }
              }}
           ]
  end

  asts = [
    quote do
      defmodule Test do
        def x(), do: 1

        defmodule Test.Y do
          @spec x() :: integer()
          def x(), do: 1
        end
      end
    end,
    quote do
      defmodule Test do
        alias Blah.Bluh
        def x(), do: 1

        defmodule Test.Y do
          @doc ""
          def x(), do: 1
        end
      end
    end
  ]

  for {ast, n} <- Enum.with_index(asts) do
    test "##{n}: sub-modules should not raise false positive error" do
      assert FunctionAnnotationOrder.run(unquote(Macro.escape(ast))) == []
    end
  end
end
