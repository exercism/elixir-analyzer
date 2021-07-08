defmodule ElixirAnalyzer.ExerciseTest.FeatureTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.Support.AnalyzerVerification.Feature

  test_exercise_analysis "perfect solution",
    comments: [] do
    defmodule Factorial do
      @answer 42

      def calc(n) do
        arg1 = n - 1
        n * calc(arg1)
      end

      def strict_calc(n) do
        arg1 = n - 1
        n * calc(arg1)
      end
    end
  end

  describe "matching function calls with _ignore" do
    @comment "calc/1 must call some other function of any arity"
    test_exercise_analysis "used function name is ignored so it can be anything",
      comments_exclude: [@comment] do
      [
        defmodule Factorial do
          def calc(n) do
            arg1 = n - 1
            n * calc(arg1)
          end
        end,
        defmodule Factorial do
          def calc(n) do
            arg1 = n - 1
            n * do_calc(arg1)
          end
        end,
        defmodule Factorial do
          def calc(n) do
            arg1 = n - 1
            n * banana(arg1)
          end
        end
      ]
    end

    test_exercise_analysis "argument name is ignored",
      comments_exclude: [@comment] do
      [
        defmodule Factorial do
          def calc(n) do
            arg1 = n - 1
            n * calc(arg2)
          end
        end,
        defmodule Factorial do
          def calc(n) do
            arg1 = n - 1
            n * calc(banana)
          end
        end,
        defmodule Factorial do
          def calc(n) do
            arg1 = n - 1
            n * calc(n - 1)
          end
        end
      ]
    end

    test_exercise_analysis "arg1 calculation method is ignored", comments_exclude: [@comment] do
      [
        defmodule Factorial do
          def calc(n) do
            arg1 = n - 1
            n * calc(arg1)
          end
        end,
        defmodule Factorial do
          def calc(n) do
            # oops, bug :)
            arg1 = n + 1
            n * calc(arg1)
          end
        end,
        defmodule Factorial do
          def calc(n) do
            arg1 = n - 2 + 1
            n * calc(arg1)
          end
        end,
        defmodule Factorial do
          def calc(n) do
            arg1 = rem(n + n - 1 - n, 1)
            n * calc(arg1)
          end
        end
      ]
    end

    test_exercise_analysis "arity is ignored",
      comments_exclude: [@comment] do
      [
        defmodule Factorial do
          def calc(n) do
            arg1 = n - 1
            n * calc(n, arg1)
          end
        end,
        defmodule Factorial do
          def calc(n) do
            arg1 = n - 1
            n * calc(arg1, n)
          end
        end,
        defmodule Factorial do
          def calc(n) do
            arg1 = n - 1
            n * calc(n, arg1, n)
          end
        end
      ]
    end

    test_exercise_analysis "lines preceding or following the desired function call are not ignored",
      comments_include: [@comment] do
      [
        defmodule Factorial do
          def calc(n) do
            1 + 2
            arg1 = n - 1
            n * calc(arg1)
          end
        end,
        defmodule Factorial do
          def calc(n) do
            something(1, 2, 3)
            IO.puts("hi")
            arg1 = n - 1
            n * calc(arg1)
          end
        end,
        defmodule Factorial do
          def calc(n) do
            something(1, 2, 3)
            arg1 = n - 1
            n * calc(arg1)
            IO.puts("hi")
          end
        end,
        defmodule Factorial do
          def calc(n) do
            arg1 = n - 1
            n * calc(arg1)
            something(1, 2, 3)
            IO.puts("hi")
          end
        end
      ]
    end
  end

  describe "matching function calls with _shallow_ignore" do
    @comment "strict_calc/1 must call some other function with one arguments named arg1"
    test_exercise_analysis "used function name is ignored so it can be anything",
      comments_exclude: [@comment] do
      [
        defmodule Factorial do
          def strict_calc(n) do
            arg1 = n - 1
            n * calc(arg1)
          end
        end,
        defmodule Factorial do
          def strict_calc(n) do
            arg1 = n - 1
            n * do_calc(arg1)
          end
        end,
        defmodule Factorial do
          def strict_calc(n) do
            arg1 = n - 1
            n * banana(arg1)
          end
        end
      ]
    end

    test_exercise_analysis "argument name is not ignored",
      comments_include: [@comment] do
      [
        defmodule Factorial do
          def strict_calc(n) do
            arg1 = n - 1
            n * calc(arg2)
          end
        end,
        defmodule Factorial do
          def strict_calc(n) do
            arg1 = n - 1
            n * calc(banana)
          end
        end,
        defmodule Factorial do
          def strict_calc(n) do
            arg1 = n - 1
            n * calc(n - 1)
          end
        end
      ]
    end

    test_exercise_analysis "exact calculation method is ignored if it two args - n and 1",
      comments_exclude: [@comment] do
      [
        defmodule Factorial do
          def strict_calc(n) do
            arg1 = n - 1
            n * calc(arg1)
          end
        end,
        defmodule Factorial do
          def strict_calc(n) do
            # oops, bug :)
            arg1 = n + 1
            n * calc(arg1)
          end
        end,
        defmodule Factorial do
          def strict_calc(n) do
            # oops, bug :)
            arg1 = foo(n, 1)
            n * calc(arg1)
          end
        end
      ]
    end

    test_exercise_analysis "calculation method must use two args - n and 1",
      comments_include: [@comment] do
      [
        defmodule Factorial do
          def strict_calc(n) do
            # oops, bug :) also wrong order
            arg1 = 1 + n
            n * calc(arg1)
          end
        end,
        defmodule Factorial do
          def strict_calc(n) do
            arg1 = n - 2 + 1
            n * calc(arg1)
          end
        end,
        defmodule Factorial do
          def strict_calc(n) do
            arg1 = rem(n + n - 1 - n, 1)
            n * calc(arg1)
          end
        end
      ]
    end

    test_exercise_analysis "arity is not ignored",
      comments_include: [@comment] do
      [
        defmodule Factorial do
          def strict_calc(n) do
            arg1 = n - 1
            n * calc(n, arg1)
          end
        end,
        defmodule Factorial do
          def strict_calc(n) do
            arg1 = n - 1
            n * calc(arg1, n)
          end
        end,
        defmodule Factorial do
          def strict_calc(n) do
            arg1 = n - 1
            n * calc(n, arg1, n)
          end
        end
      ]
    end

    test_exercise_analysis "lines preceding or following the desired function call are not ignored",
      comments_include: [@comment] do
      [
        defmodule Factorial do
          def strict_calc(n) do
            1 + 2
            arg1 = n - 1
            n * calc(arg1)
          end
        end,
        defmodule Factorial do
          def strict_calc(n) do
            something(1, 2, 3)
            IO.puts("hi")
            arg1 = n - 1
            n * calc(arg1)
          end
        end,
        defmodule Factorial do
          def strict_calc(n) do
            something(1, 2, 3)
            arg1 = n - 1
            n * calc(arg1)
            IO.puts("hi")
          end
        end,
        defmodule Factorial do
          def strict_calc(n) do
            arg1 = n - 1
            n * calc(arg1)
            something(1, 2, 3)
            IO.puts("hi")
          end
        end
      ]
    end
  end

  describe "matching module attributes with ignore and shallow_ignore" do
    @comment_any "there must be any module attribute with any value and any name"
    @comment_any_42_and_answer "there must be any module attribute with the value 42, and any module attribute with the name 'answer'"

    test_exercise_analysis "name and value matched",
      comments_exclude: [@comment_any, @comment_any_42_and_answer] do
      [
        defmodule Factorial do
          @answer 42
        end
      ]
    end

    test_exercise_analysis "two separate module attributes",
      comments_exclude: [@comment_any, @comment_any_42_and_answer] do
      [
        defmodule Factorial do
          @whats_this 42
          @answer :i_dont_know
        end
      ]
    end

    test_exercise_analysis "missing answer and/or missing 42",
      comments_include: [@comment_any_42_and_answer] do
      [
        defmodule Factorial do
          @not_answer 55
          @answer :i_dont_know
        end,
        defmodule Factorial do
          @answer :not_42
        end,
        defmodule Factorial do
          @not_answer 42
        end,
        defmodule Factorial do
          @not_answer :not_42
        end,
        defmodule Factorial do
          @moduledoc "Calcualte the factorial"
        end
      ]
    end

    test_exercise_analysis "no module attributes at all",
      comments_include: [@comment_any, @comment_any_42_and_answer] do
      [
        defmodule Factorial do
        end,
        defmodule Factorial do
          def calc(n) do
            n * calc(n - 1)
          end
        end
      ]
    end
  end
end
