defmodule ElixirAnalyzer.ExerciseTest.SquareRootTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.SquareRoot

  test_exercise_analysis "example solution",
    comments: [] do
    defmodule SquareRoot do
      def calculate(1), do: 1

      def calculate(radicand) do
        guess = div(radicand, 2)
        calculate(radicand, guess)
      end

      def calculate(radicand, guess) do
        new_guess = div(guess + div(radicand, guess), 2)

        if new_guess == guess do
          guess
        else
          calculate(radicand, new_guess)
        end
      end
    end
  end

  describe "forbids built-in srqt functions" do
    test_exercise_analysis "detects Float.pow",
      comments: [Constants.square_root_do_not_use_built_in_sqrt()] do
      [
        defmodule SquareRoot do
          def calculate(n), do: Float.pow(n / 1, 0.5) |> floor()
        end,
        defmodule SquareRoot do
          import Float, only: [pow: 2]
          def calculate(n), do: pow(n / 1, 0.5) |> floor()
        end,
        defmodule SquareRoot do
          alias Float, as: F
          def calculate(n), do: F.pow(n / 1, 0.5) |> floor()
        end
      ]
    end
  end
end
