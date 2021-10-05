defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.DocSpecOrderTest do
  use ExUnit.Case
  alias ElixirAnalyzer.Comment
  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.ExerciseTest.CommonChecks.DocSpecOrder

  setup_all do
    error = [
      {:fail,
       %Comment{
         type: :informative,
         name: Constants.solution_doc_spec_order(),
         comment: Constants.solution_doc_spec_order()
       }}
    ]

    [error: error]
  end

  test "wrong order crashes", %{error: error} do
    ast =
      quote do
        defmodule Test do
          @spec x()
          @doc ""
          def x()
        end
      end

    assert DocSpecOrder.run(ast) == error
  end

  test "works for def, defp, defmacro, defmacrop, defguard, and defguardp", %{error: error} do
    ast =
      quote do
        defmodule Test do
          @spec x()
          @doc ""
          def x()
        end
      end

    assert DocSpecOrder.run(ast) == error

    ast =
      quote do
        defmodule Test do
          @spec x()
          @doc ""
          defp x()
        end
      end

    assert DocSpecOrder.run(ast) == error

    ast =
      quote do
        defmodule Test do
          @spec x()
          @doc ""
          defmacro x()
        end
      end

    assert DocSpecOrder.run(ast) == error

    ast =
      quote do
        defmodule Test do
          @spec x()
          @doc ""
          defmacrop x()
        end
      end

    assert DocSpecOrder.run(ast) == error

    ast =
      quote do
        defmodule Test do
          @spec x()
          @doc ""
          defguard x()
        end
      end

    assert DocSpecOrder.run(ast) == error

    ast =
      quote do
        defmodule Test do
          @spec x()
          @doc ""
          defguardp x()
        end
      end

    assert DocSpecOrder.run(ast) == error
  end

  test "non related definitions will not make crash" do
    ast =
      quote do
        @doc ""
        def x

        @spec y
        def y
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

  test "function definition order doesnt impact", %{error: error} do
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

    assert DocSpecOrder.run(ast) == error
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
end
