defmodule ElixirAnalyzer.ExerciseTest.GuessingGameTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.GuessingGame

  test_exercise_analysis "example solution",
    comments: [] do
    defmodule GuessingGame do
      def compare(secret_number, guess \\ :no_guess)

      def compare(_secret_number, guess) when guess == :no_guess do
        "Make a guess"
      end

      def compare(secret_number, guess) when guess == secret_number do
        "Correct"
      end

      def compare(secret_number, guess)
          when guess == secret_number + 1 or
                 guess == secret_number - 1 do
        "So close"
      end

      def compare(secret_number, guess) when guess > secret_number do
        "Too high"
      end

      def compare(secret_number, guess) when guess < secret_number do
        "Too low"
      end
    end
  end

  test_exercise_analysis "another acceptable solutions",
    comments: [] do
    [
      defmodule GuessingGame do
        def compare(secret_number, g \\ :no_guess)

        def compare(secret_number, secret_number) do
          "Correct"
        end

        def compare(secret_number, g) when g in [secret_number + 1, secret_number - 1] do
          "So close"
        end

        def compare(_secret_number, :no_guess) do
          "Make a guess"
        end

        def compare(secret_number, g) when g > secret_number do
          "Too high"
        end

        def compare(_secret_number, g) do
          "Too low"
        end
      end,
      defmodule GuessingGame do
        def compare(secret_number, x \\ :no_guess)

        def compare(_secret_number, :no_guess) do
          "Make a guess"
        end

        def compare(secret_number, secret_number) do
          "Correct"
        end

        def compare(secret_number, x) when x >= secret_number + 2 do
          "Too high"
        end

        def compare(secret_number, x) when x <= secret_number - 2 do
          "Too low"
        end

        def compare(secret_number, x) when x >= secret_number + 1 do
          "So close"
        end

        def compare(secret_number, x) when x <= secret_number - 1 do
          "So close"
        end
      end
    ]
  end

  test_exercise_analysis "requires using default arguments",
    comments_include: [Constants.guessing_game_use_default_argument()] do
    [
      defmodule GuessingGame do
        def compare(x), do: compare(x, :no_guess)
      end,
      defmodule GuessingGame do
        def compare(x) do
          "Make a guess"
        end
      end
    ]
  end

  test_exercise_analysis "detects technically correct but discouraged default argument without a function head",
    comments_exclude: [Constants.guessing_game_use_default_argument()] do
    [
      defmodule GuessingGame do
        def compare(_secret_number, guess \\ :no_guess) when guess == :no_guess do
          "Make a guess"
        end

        def compare(secret_number, guess) when guess == secret_number do
          "Correct"
        end

        # other cases
      end,
      defmodule GuessingGame do
        def compare(_secret_number, :no_guess \\ :no_guess) do
          "Make a guess"
        end

        def compare(secret_number, guess) when guess == secret_number do
          "Correct"
        end

        # other cases
      end,
      defmodule GuessingGame do
        # other cases

        def compare(secret_number, guess) when guess < secret_number and is_integer(guess) do
          "Too low"
        end

        def compare(_secret_number, guess \\ :no_guess) do
          "Make a guess"
        end
      end
    ]
  end

  test_exercise_analysis "requires using multiple clause functions",
    comments_include: [Constants.guessing_game_use_multiple_clause_functions()],
    comments_exclude: [Constants.guessing_game_use_default_argument()] do
    [
      defmodule GuessingGame do
        def compare(secret_number, guess \\ :no_guess) do
          case guess do
            :no_guess -> "Make a guess"
            ^secret_number -> "Correct"
            guess when guess == secret_number + 1 -> "So close"
            guess when guess == secret_number - 1 -> "So close"
            guess when guess > secret_number -> "Too high"
            guess when guess < secret_number -> "Too low"
          end
        end
      end,
      defmodule GuessingGame do
        def compare(secret_number, guess \\ :no_guess) do
          cond do
            guess == :no_guess -> "Make a guess"
            guess == secret_number -> "Correct"
            guess == secret_number + 1 -> "So close"
            guess == secret_number - 1 -> "So close"
            guess > secret_number -> "Too high"
            guess < secret_number -> "Too low"
          end
        end
      end,
      defmodule GuessingGame do
        def compare(secret_number, guess \\ :no_guess) do
          if guess == :no_guess do
            "Make a guess"
          else
            if guess == secret_number do
              "Correct"
            else
              if guess == secret_number + 1 do
                "So close"
              else
                if guess == secret_number - 1 do
                  "So close"
                else
                  if guess > secret_number do
                    "Too high"
                  else
                    if guess < secret_number do
                      "Too low"
                    end
                  end
                end
              end
            end
          end
        end
      end
    ]
  end

  test_exercise_analysis "requires using guards",
    comments_include: [Constants.guessing_game_use_guards()],
    comments_exclude: [Constants.guessing_game_use_default_argument()] do
    [
      defmodule GuessingGame do
        def compare(secret_number, guess \\ :no_guess) do
          cond do
            guess == :no_guess -> "Make a guess"
            guess == secret_number -> "Correct"
            guess == secret_number + 1 -> "So close"
            guess == secret_number - 1 -> "So close"
            guess > secret_number -> "Too high"
            guess < secret_number -> "Too low"
          end
        end
      end,
      defmodule GuessingGame do
        def compare(secret_number, guess \\ :no_guess) do
          if guess == :no_guess do
            "Make a guess"
          else
            if guess == secret_number do
              "Correct"
            else
              if guess == secret_number + 1 do
                "So close"
              else
                if guess == secret_number - 1 do
                  "So close"
                else
                  if guess > secret_number do
                    "Too high"
                  else
                    if guess < secret_number do
                      "Too low"
                    end
                  end
                end
              end
            end
          end
        end
      end
    ]
  end

  test_exercise_analysis "detects different usages of guards",
    comments_exclude: [Constants.guessing_game_use_guards()] do
    [
      defmodule GuessingGame do
        def compare(secret_number, g) when g in [secret_number + 1, secret_number - 1] do
          "So close"
        end
      end,
      defmodule GuessingGame do
        def compare(secret_number, g) when g in [secret_number + 1, secret_number - 1] do
          # unnecessary operation
          1 + 2
          "So close"
        end
      end,
      defmodule GuessingGame do
        def compare(secret_number, g) when g in [secret_number + 1, secret_number - 1] do
          "So close"
        end
      end,
      defmodule GuessingGame do
        def compare(secret_number, g) when g + 1 == secret_number do
          "So close"
        end
      end,
      defmodule GuessingGame do
        def compare(secret_number, g) when g == secret_number + 1 do
          "So close"
        end
      end,
      defmodule GuessingGame do
        def compare(secret_number, g) when g - 1 == secret_number do
          "So close"
        end
      end,
      defmodule GuessingGame do
        def compare(secret, g) when secret == g - 1 do
          "So close"
        end
      end,
      defmodule GuessingGame do
        def compare(secret, g) when secret == g - 1 do
          # unnecessary but technically correct
          x = "So"
          y = "close"
          x <> " " <> y
        end
      end,
      defmodule GuessingGame do
        def compare(x, y) when x == y do
          "Correct"
        end
      end,
      defmodule GuessingGame do
        def compare(secret_number, g) when g > secret_number do
          "Too high"
        end
      end,
      defmodule GuessingGame do
        def compare(s, g) when g < s do
          "Too low"
        end
      end
    ]
  end
end
