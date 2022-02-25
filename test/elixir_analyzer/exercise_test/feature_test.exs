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
          @moduledoc "Calculate the factorial"
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

  describe "types of blocks" do
    defmodule Blocks do
      use ElixirAnalyzer.ExerciseTest

      feature "single line" do
        comment "single line"

        form do
          :a
        end
      end

      feature "two lines" do
        comment "two lines"

        form do
          :a
          :b
        end
      end

      feature "single line block" do
        comment "single line block"

        form do
          !:a
        end
      end
    end

    defmodule BlocksTest do
      use ElixirAnalyzer.ExerciseTestCase,
        exercise_test_module: Blocks

      test_exercise_analysis "empty",
        comments: ["single line block", "two lines", "single line"] do
        defmodule Module do
        end
      end

      test_exercise_analysis "two lines",
        comments: ["single line block"],
        comments_exclude: ["single line", "two lines"] do
        defmodule Module do
          def foo do
            :a
            :b
          end
        end
      end

      test_exercise_analysis "single line block",
        comments: ["two lines"],
        comments_exclude: ["single line", "single line block"] do
        defmodule Module do
          def foo do
            !:a
          end
        end
      end
    end
  end

  describe "other features" do
    defmodule Coverage do
      use ElixirAnalyzer.ExerciseTest

      feature "any" do
        comment "any"
        find :any

        form do
          :ok
        end

        form do
          :error
        end
      end

      feature "all" do
        comment "all"
        find :all

        form do
          :ok
        end

        form do
          :error
        end
      end

      feature "suppress_if" do
        comment "suppress_if"
        suppress_if "all", :pass

        form do
          :error
        end
      end

      feature "depth 2" do
        comment "depth 2"
        depth 2

        form do
          :ok
        end
      end

      feature "depth 3" do
        comment "depth 3"
        depth 3

        form do
          :ok
        end
      end
    end

    defmodule CoverageTest do
      use ElixirAnalyzer.ExerciseTestCase,
        exercise_test_module: Coverage

      test_exercise_analysis "has :ok at depth 2",
        comments: ["depth 3", "all", "suppress_if"],
        comments_exclude: ["any", "depth 2"] do
        defmodule Module do
          def foo, do: :ok
        end
      end

      test_exercise_analysis "has :error, and :ok at depth 3",
        comments: ["depth 2"],
        comments_exclude: ["any", "all", "depth 3", "suppress_if"] do
        defmodule Module do
          defmodule SubModule do
            def foo, do: :ok
          end

          def bar, do: :error
        end
      end

      test_exercise_analysis "empty",
        comments: ["depth 2", "depth 3", "any", "all", "suppress_if"] do
        defmodule Module do
        end
      end
    end
  end

  describe "incorrect use raises errors" do
    unsupported =
      "Unsupported expression `unsupported`.\nThe macro `feature` supports expressions: comment, type, find, suppress_if, depth, form.\n"

    assert_raise RuntimeError, unsupported, fn ->
      defmodule Failure do
        use ElixirAnalyzer.ExerciseTest

        feature "check" do
          comment "this will fail"
          unsupported(:woops)

          form do
            _ignore
          end
        end
      end
    end

    assert_raise RuntimeError, "Comment must be defined for each feature test", fn ->
      defmodule Failure do
        use ElixirAnalyzer.ExerciseTest

        feature "check" do
          type :informative

          form do
            true
          end
        end
      end
    end

    wrong_type =
      "Unsupported type `unsupported`.\nThe macro `feature` supports the following types: essential, actionable, informative, celebratory.\n"

    assert_raise RuntimeError, wrong_type, fn ->
      defmodule Failure do
        use ElixirAnalyzer.ExerciseTest

        feature "check" do
          type :unsupported

          form do
            true
          end
        end
      end
    end
  end
end
