defmodule ElixirAnalyzer.ExerciseTest.AssertCallTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.Support.AnalyzerVerification.AssertCall

  test_exercise_analysis "perfect solution",
    comments: [] do
    [
      defmodule AssertCallVerification do
        def function() do
          x = List.first([1, 2, 3])
          result = helper()
          IO.puts(result)

          private_helper() |> IO.puts()
        end

        def helper do
          :helped
        end

        defp private_helper do
          :privately_helped
        end
      end,
      # call helper with capture notation
      defmodule AssertCallVerification do
        def function() do
          x = List.first([1, 2, 3])
          result = Enum.map(result, &helper/0)
          IO.puts(result)

          private_helper() |> IO.puts()
        end

        def helper do
          :helped
        end

        defp private_helper do
          :privately_helped
        end
      end,
      # function definitions with unnecessary but harmless rescue blocks
      defmodule AssertCallVerification do
        def function() do
          x = List.first([1, 2, 3])
          result = helper()
          IO.puts(result)

          private_helper() |> IO.puts()
        rescue
          ArgumentError -> :oops
          _ -> :what
        end

        def helper do
          :helped
        end

        defp private_helper do
          :privately_helped
        end
      end
    ]
  end

  test_exercise_analysis "finds calls even if they're in rescue blocks",
    comments: [] do
    [
      # def + rescue and try + rescue
      defmodule AssertCallVerification do
        def function() do
          try do
            x = List.first([1, 2, 3])
          rescue
            result = helper()
            IO.puts(result)
          end
        rescue
          ArgumentError -> :oops
          _ -> private_helper() |> IO.puts()
        end

        def helper do
          :helped
        end

        defp private_helper do
          :privately_helped
        end
      end
    ]
  end

  test_exercise_analysis "missing local call from anywhere in solution",
    comments: [
      "didn't find a local call to helper/0",
      "didn't find a local call to helper/0 within function/0"
    ] do
    defmodule AssertCallVerification do
      def function() do
        x = List.last([1, 2, 3])
        private_helper() |> IO.puts()
      end

      def helper do
        :helped
      end

      defp private_helper do
        :privately_helped
      end
    end
  end

  test_exercise_analysis "indirect call via a helper function",
    comments: [] do
    defmodule AssertCallVerification do
      def function() do
        x = List.first([1, 2, 3])
        other()
        IO.puts("1")
      end

      def other() do
        result = helper()
        private_helper() |> IO.puts()
      end

      def helper do
        :helped
      end

      defp private_helper do
        :privately_helped
      end
    end
  end

  test_exercise_analysis "finds local calls if they use the module name to reference the function",
    comments: [] do
    [
      defmodule AssertCallVerification do
        def function() do
          x = List.first([1, 2, 3])
          result = AssertCallVerification.helper()
          IO.puts(result)

          AssertCallVerification.private_helper() |> IO.puts()
        end

        def helper do
          :helped
        end

        defp private_helper do
          :privately_helped
        end
      end,
      # call helper with capture notation
      defmodule AssertCallVerification do
        def function() do
          x = List.first([1, 2, 3])
          result = Enum.map(result, &AssertCallVerification.helper/0)
          IO.puts(result)

          private_helper() |> IO.puts()
        end

        def helper do
          :helped
        end

        defp private_helper do
          :privately_helped
        end
      end,
      # indirect call
      defmodule AssertCallVerification do
        def function() do
          x = List.first([1, 2, 3])
          result = AssertCallVerification.extra_helper()
          IO.puts(result)

          AssertCallVerification.private_helper() |> IO.puts()
        end

        def extra_helper() do
          AssertCallVerification.helper()
        end

        def helper do
          :helped
        end

        defp private_helper do
          :privately_helped
        end
      end
    ]
  end

  test_exercise_analysis "finds local calls if they use __MODULE__ to reference the function",
    comments: [] do
    [
      defmodule AssertCallVerification do
        def function() do
          x = List.first([1, 2, 3])
          result = __MODULE__.helper()
          IO.puts(result)

          __MODULE__.private_helper() |> IO.puts()
        end

        def helper do
          :helped
        end

        defp private_helper do
          :privately_helped
        end
      end,
      # call helper with capture notation
      defmodule AssertCallVerification do
        def function() do
          x = List.first([1, 2, 3])
          result = Enum.map(result, &__MODULE__.helper/0)
          IO.puts(result)

          private_helper() |> IO.puts()
        end

        def helper do
          :helped
        end

        defp private_helper do
          :privately_helped
        end
      end,
      # indirect call
      defmodule AssertCallVerification do
        def function() do
          x = List.first([1, 2, 3])
          result = __MODULE__.extra_helper()
          IO.puts(result)

          __MODULE__.private_helper() |> IO.puts()
        end

        def extra_helper() do
          __MODULE__.helper()
        end

        def helper do
          :helped
        end

        defp private_helper do
          :privately_helped
        end
      end
    ]
  end

  test_exercise_analysis "doesn't find local calls if they're same-named functions from a different module",
    comments: [
      "didn't find a local call to helper/0",
      "didn't find a local call to helper/0 within function/0",
      "didn't find a local call to private_helper/0",
      "didn't find a local call to private_helper/0 within function/0"
    ] do
    [
      defmodule AssertCallVerification do
        def function() do
          x = List.first([1, 2, 3])
          result = OtherModule.helper()
          IO.puts(result)

          OtherModule.private_helper() |> IO.puts()
        end

        def helper do
          :helped
        end

        defp private_helper do
          :privately_helped
        end
      end,
      # call helper with capture notation
      defmodule AssertCallVerification do
        def function() do
          x = List.first([1, 2, 3])
          result = Enum.map(result, &OtherModule.helper/0)
          IO.puts(result)

          OtherModule.private_helper() |> IO.puts()
        end

        def helper do
          :helped
        end

        defp private_helper do
          :privately_helped
        end
      end
    ]
  end

  test_exercise_analysis "missing call to IO.puts/1 in solution",
    comments: [
      "didn't find a call to IO.puts/1 anywhere in solution",
      "didn't find a call to IO.puts/1 in function/0"
    ] do
    defmodule AssertCallVerification do
      def function() do
        l = List.flatten([1, 2, 3])
        result = helper()
        private_helper()
      end

      def helper do
        :helped
      end

      defp private_helper do
        :privately_helped
      end
    end
  end

  test_exercise_analysis "indirect call to IO.puts/1 in function/0 via helper function",
    comments: [] do
    defmodule AssertCallVerification do
      def function() do
        l = List.first([1, 2, 3])
        result = helper()
        private_helper() |> other()
      end

      def other(x) do
        IO.puts(x)
      end

      def helper do
        :helped
      end

      defp private_helper do
        :privately_helped
      end
    end
  end

  test_exercise_analysis "indirect call to a List function in function/0 via helper function",
    comments: [] do
    defmodule AssertCallVerification do
      def function() do
        result = helper()
        IO.puts(result)

        private_helper() |> IO.puts()
      end

      def helper do
        l = List.first([1, 2, 3])
        :helped
      end

      defp private_helper do
        :privately_helped
      end
    end
  end

  test_exercise_analysis "indirect call to a List function in function/0 via captured helper function",
    comments: [] do
    defmodule AssertCallVerification do
      def function() do
        result = helper()
        IO.puts(result)

        result |> Enum.map(&private_helper/1) |> IO.puts()
      end

      def helper do
        :helped
      end

      defp private_helper(list) do
        l = List.first(list)
        :privately_helped
      end
    end
  end

  test_exercise_analysis "missing call to a List function in solution",
    comments: [
      "didn't find a call to a List function",
      "didn't find a call to a List function in function/0",
      "mock.constant"
    ] do
    defmodule AssertCallVerification do
      def function() do
        result = helper()
        IO.puts(result)

        private_helper() |> IO.puts()
      end

      def helper do
        :helped
      end

      defp private_helper do
        :privately_helped
      end
    end
  end

  test_exercise_analysis "usages of the underscore don't fool the missing call check",
    comments: [
      "didn't find a call to a List function",
      "didn't find a call to a List function in function/0",
      "mock.constant",
      "elixir.solution.last_line_assignment"
    ] do
    defmodule AssertCallVerification do
      def function() do
        result = helper()
        IO.puts(result)

        2 * 3

        _ = private_helper() |> IO.puts()
      end

      def helper do
        :helped
      end

      defp private_helper do
        :privately_helped
      end
    end
  end

  test_exercise_analysis "function without parentheses doesn't get matched",
    # Instead, we rely on the compiler warning
    comments: [
      "didn't find a local call to helper/0",
      "didn't find a local call to helper/0 within function/0"
    ] do
    defmodule AssertCallVerification do
      def function() do
        x = List.first([1, 2, 3])
        result = helper
        IO.puts(result)

        private_helper() |> IO.puts()
      end

      def helper do
        :helped
      end

      defp private_helper do
        :privately_helped
      end
    end
  end

  describe "test errors" do
    test "undefined comment" do
      assert_raise RuntimeError, "Comment must be defined for each assert_call test", fn ->
        defmodule AssertFail do
          use ElixirAnalyzer.ExerciseTest

          assert_call "some assert_call" do
          end
        end
      end
    end

    test "unsupported expression" do
      message =
        "Unsupported expression `unsupported`.\nThe macro `assert_call` supports expressions: comment, type, calling_fn, called_fn, suppress_if.\n"

      assert_raise RuntimeError, message, fn ->
        defmodule AssertFail do
          use ElixirAnalyzer.ExerciseTest

          assert_call "some assert_call" do
            comment "some comment"
            unsupported(true)
          end
        end
      end
    end

    test "unsupported type" do
      message =
        "Unsupported type `unsupported`.\nThe macro `assert_call` supports the following types: essential, actionable, informative, celebratory.\n"

      assert_raise RuntimeError, message, fn ->
        defmodule AssertFail do
          use ElixirAnalyzer.ExerciseTest

          assert_call "some assert_call" do
            comment "some comment"
            type :unsupported
          end
        end
      end
    end

    test "non-atomic called function module" do
      message = "calling function signature requires :module to be nil or a module atom, got: 42"

      assert_raise ArgumentError, message, fn ->
        defmodule AssertFail do
          use ElixirAnalyzer.ExerciseTest

          assert_call "some assert_call" do
            comment "some comment"
            called_fn module: 42, name: :floor
          end
        end
      end
    end

    test "non-atomic calling function module" do
      message = "calling function signature requires :module to be nil or a module atom, got: 42"

      assert_raise ArgumentError, message, fn ->
        defmodule AssertFail do
          use ElixirAnalyzer.ExerciseTest

          assert_call "some assert_call" do
            comment "some comment"
            called_fn name: :floor
            calling_fn module: 42, name: :fourty_two
          end
        end
      end
    end

    test "non-atomic called function name" do
      message = "calling function signature requires :name to be an atom, got: 42"

      assert_raise ArgumentError, message, fn ->
        defmodule AssertFail do
          use ElixirAnalyzer.ExerciseTest

          assert_call "some assert_call" do
            comment "some comment"
            called_fn module: Enum, name: 42
          end
        end
      end
    end

    test "non-atomic calling function name" do
      message = "calling function signature requires :name to be an atom, got: 42"

      assert_raise ArgumentError, message, fn ->
        defmodule AssertFail do
          use ElixirAnalyzer.ExerciseTest

          assert_call "some assert_call" do
            comment "some comment"
            calling_fn module: Enum, name: 42
          end
        end
      end
    end

    test "nil  calling function name" do
      message = "calling function signature requires :module to be an atom"

      assert_raise ArgumentError, message, fn ->
        defmodule AssertFail do
          use ElixirAnalyzer.ExerciseTest

          assert_call "some assert_call" do
            comment "some comment"
            calling_fn name: nil
          end
        end
      end
    end
  end
end
