defmodule ElixirAnalyzer.ExerciseTest.AssertCallTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.Support.AnalyzerVerification.AssertCall

  test_exercise_analysis "perfect solution",
    comments: [] do
    defmodule AssertCallVerification do
      def function() do
        x = List.first([1, 2, 3])
        result = helper()
        IO.puts(result)
        :rand.normal()

        private_helper() |> IO.puts()
      end

      def helper do
        A.B.C.efg()
        :helped
      end

      defp private_helper do
        :privately_helped
      end
    end
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
        :rand.normal()
      end

      alias A.B.C, as: A

      def helper do
        :helped
        A.efg()
      end

      defp private_helper do
        :privately_helped
      end
    end
  end

  test_exercise_analysis "missing local call from specific function solution",
    comments: [
      "didn't find a local call to helper/0 within function/0",
      "didn't find a local call to private_helper/0 within function/0"
    ] do
    defmodule AssertCallVerification do
      def function() do
        x = List.first([1, 2, 3])
        other()
        IO.puts("1")
        :rand.normal()
      end

      def other() do
        result = helper()
        private_helper() |> IO.puts()
      end

      def helper do
        import A.B.C
        efg()
        :helped
      end

      defp private_helper do
        :privately_helped
      end
    end
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
        :rand.normal()
      end

      def helper do
        alias A.B.C
        C.efg()
        :helped
      end

      defp private_helper do
        :privately_helped
      end
    end
  end

  test_exercise_analysis "missing call to IO.puts/1 in function/0 solution",
    comments: [
      "didn't find a call to IO.puts/1 in function/0"
    ] do
    defmodule AssertCallVerification do
      def function() do
        l = List.first([1, 2, 3])
        result = helper()
        private_helper() |> other()
        :rand.normal()
      end

      def other(x) do
        IO.puts(x)
      end

      alias A.B.C, as: D

      def helper do
        D.efg()
        :helped
      end

      defp private_helper do
        :privately_helped
      end
    end
  end

  test_exercise_analysis "missing call to a List function in function/0 solution",
    comments: [
      "didn't find a call to a List function in function/0",
      "mock.constant"
    ] do
    defmodule AssertCallVerification do
      def function() do
        result = helper()
        IO.puts(result)

        :rand.normal()
        private_helper() |> IO.puts()
      end

      def helper do
        l = List.first([1, 2, 3])
        :helped
      end

      defp private_helper do
        alias A.B
        B.C.efg()
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

        :rand.normal()
        private_helper() |> IO.puts()
      end

      alias A.{X.Y, B.C}

      def helper do
        C.efg()
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
      "mock.constant"
    ] do
    defmodule AssertCallVerification do
      def function() do
        result = helper()
        IO.puts(result)

        :rand.normal()
        2 * 3

        _ = private_helper() |> IO.puts()
      end

      alias A.{B.C, X.Y}

      def helper do
        C.efg()
        :helped
      end

      defp private_helper do
        :privately_helped
      end
    end
  end

  test_exercise_analysis "missing any :rand call from anywhere in solution",
    comments: [
      "didn't find a call to :rand.normal anywhere in solution",
      "didn't find a call to :rand.normal/0 in function/0",
      "didn't find a call to a :rand function in function/0",
      "didn't find any call to a :rand function"
    ] do
    defmodule AssertCallVerification do
      def function() do
        x = List.first([1, 2, 3])
        result = helper()
        IO.puts(result)

        private_helper() |> IO.puts()
      end

      def helper do
        import A.B
        C.efg()
        :helped
      end

      defp private_helper do
        :privately_helped
      end
    end
  end

  test_exercise_analysis "missing :rand.random call from anywhere in solution",
    comments: [
      "didn't find a call to :rand.normal anywhere in solution",
      "didn't find a call to :rand.normal/0 in function/0"
    ] do
    defmodule AssertCallVerification do
      def function() do
        x = List.first([1, 2, 3])
        result = helper()
        IO.puts(result)

        private_helper() |> IO.puts()

        r = :rand.uniform_real()
      end

      import A

      def helper do
        B.C.efg()
        :helped
      end

      defp private_helper do
        :privately_helped
      end
    end
  end

  test_exercise_analysis "missing :rand.random call in function/0",
    comments: [
      "didn't find a call to :rand.normal/0 in function/0",
      "didn't find a call to a :rand function in function/0"
    ] do
    defmodule AssertCallVerification do
      def function() do
        x = List.first([1, 2, 3])
        result = helper()
        IO.puts(result)

        private_helper() |> IO.puts()
      end

      alias A.B, as: X
      X.C.efg()

      def helper do
        r = :rand.normal()
        :helped
      end

      defp private_helper do
        :privately_helped
      end
    end
  end
end
