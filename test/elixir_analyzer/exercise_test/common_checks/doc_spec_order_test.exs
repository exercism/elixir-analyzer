defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.DocSpecOrderTest do
  use ExUnit.Case
  alias ElixirAnalyzer.Comment
  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.ExerciseTest.CommonChecks.DocSpecOrder

  test "wrong order crashes" do
    ast =
      quote do
        defmodule Test do
          @spec x()
          @doc ""
          def x()
        end
      end

    assert DocSpecOrder.run(ast) == [
             {:fail,
              %Comment{
                type: :informative,
                name: Constants.solution_doc_spec_order(),
                comment: Constants.solution_doc_spec_order(),
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
           name: Constants.solution_doc_spec_order(),
           comment: Constants.solution_doc_spec_order(),
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

    assert DocSpecOrder.run(ast) == order_error.("def", "x")

    ast =
      quote do
        defmodule Test do
          @spec x()
          @doc ""
          defp x()
        end
      end

    assert DocSpecOrder.run(ast) == order_error.("defp", "x")

    ast =
      quote do
        defmodule Test do
          @spec x()
          @doc ""
          defmacro x()
        end
      end

    assert DocSpecOrder.run(ast) == order_error.("defmacro", "x")

    ast =
      quote do
        defmodule Test do
          @spec x()
          @doc ""
          defmacrop x()
        end
      end

    assert DocSpecOrder.run(ast) == order_error.("defmacrop", "x")

    ast =
      quote do
        defmodule Test do
          @spec x()
          @doc ""
          defguard x()
        end
      end

    assert DocSpecOrder.run(ast) == order_error.("defguard", "x")

    ast =
      quote do
        defmodule Test do
          @spec x()
          @doc ""
          defguardp x()
        end
      end

    assert DocSpecOrder.run(ast) == order_error.("defguardp", "x")
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

    assert DocSpecOrder.run(ast) == []
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

    assert DocSpecOrder.run(ast) == []
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

    assert DocSpecOrder.run(ast) == [
             {:fail,
              %Comment{
                type: :informative,
                name: Constants.solution_doc_spec_order(),
                comment: Constants.solution_doc_spec_order(),
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

    assert DocSpecOrder.run(ast) == []
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

    assert DocSpecOrder.run(ast) == []
  end

  test "different @spec location works" do
    ast =
      quote do
        defmodule Test do
          def empty?(list) when list == [], do: true
          @spec empty?(list()) :: boolean()
          def empty?(_), do: false
        end
      end

    assert DocSpecOrder.run(ast) == []
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

    assert DocSpecOrder.run(ast) == []
  end

  test "spec with parameter works" do
    ast =
      quote do
        defmodule Test do
          @spec is_one(number)
          def is_one(number), do: number == 1
        end
      end

    assert DocSpecOrder.run(ast) == []
  end

  test "@doc and @spec between two definitions works" do
    ast =
      quote do
        defmodule Test do
          def a(x \\ [])
          @doc ""
          @spec a(list()) :: atom()
          def a([]), do: :empty
          def a(_), do: :full
        end
      end

    assert DocSpecOrder.run(ast) == []
  end
end
