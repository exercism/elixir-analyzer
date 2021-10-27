defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.PrivateHelperFunctions.PacmanRulesTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.PacmanRules

  alias ElixirAnalyzer.Constants

  test_exercise_analysis "solution with private helpers",
    comments: [] do
    defmodule Rules do
      defguardp is_bool(bool) when bool == true or bool == false

      defmacrop super_and(left, right) do
        quote do: unquote(left) and unquote(right)
      end

      defp do_or(left, right), do: left or right

      def eat_ghost?(power_pellet_active, touching_ghost) when is_bool(touching_ghost) do
        super_and(power_pellet_active, touching_ghost)
      end

      def score?(touching_power_pellet, touching_dot) do
        do_or(touching_power_pellet, touching_dot)
      end

      def lose?(power_pellet_active, touching_ghost) do
        not power_pellet_active and touching_ghost
      end

      def win?(has_eaten_all_dots, power_pellet_active, touching_ghost) do
        has_eaten_all_dots and not lose?(power_pellet_active, touching_ghost)
      end
    end
  end

  test_exercise_analysis "solution with public guard",
    comments: [Constants.solution_private_helper_functions()] do
    defmodule Rules do
      defguard is_bool(bool) when bool == true or bool == false

      defmacrop super_and(left, right) do
        quote do: unquote(left) and unquote(right)
      end

      defp do_or(left, right), do: left or right

      def eat_ghost?(power_pellet_active, touching_ghost) when is_bool(touching_ghost) do
        super_and(power_pellet_active, touching_ghost)
      end

      def score?(touching_power_pellet, touching_dot) do
        do_or(touching_power_pellet, touching_dot)
      end

      def lose?(power_pellet_active, touching_ghost) do
        not power_pellet_active and touching_ghost
      end

      def win?(has_eaten_all_dots, power_pellet_active, touching_ghost) do
        has_eaten_all_dots and not lose?(power_pellet_active, touching_ghost)
      end
    end
  end

  test_exercise_analysis "solution with public macro",
    comments: [Constants.solution_private_helper_functions()] do
    defmodule Rules do
      defguardp is_bool(bool) when bool == true or bool == false

      defmacro super_and(left, right) do
        quote do: unquote(left) and unquote(right)
      end

      defp do_or(left, right), do: left or right

      def eat_ghost?(power_pellet_active, touching_ghost) when is_bool(touching_ghost) do
        super_and(power_pellet_active, touching_ghost)
      end

      def score?(touching_power_pellet, touching_dot) do
        do_or(touching_power_pellet, touching_dot)
      end

      def lose?(power_pellet_active, touching_ghost) do
        not power_pellet_active and touching_ghost
      end

      def win?(has_eaten_all_dots, power_pellet_active, touching_ghost) do
        has_eaten_all_dots and not lose?(power_pellet_active, touching_ghost)
      end
    end
  end

  test_exercise_analysis "solution with public def",
    comments: [Constants.solution_private_helper_functions()] do
    defmodule Rules do
      defguardp is_bool(bool) when bool == true or bool == false

      defmacrop super_and(left, right) do
        quote do: unquote(left) and unquote(right)
      end

      def do_or(left, right), do: left or right

      def eat_ghost?(power_pellet_active, touching_ghost) when is_bool(touching_ghost) do
        super_and(power_pellet_active, touching_ghost)
      end

      def score?(touching_power_pellet, touching_dot) do
        do_or(touching_power_pellet, touching_dot)
      end

      def lose?(power_pellet_active, touching_ghost) do
        not power_pellet_active and touching_ghost
      end

      def win?(has_eaten_all_dots, power_pellet_active, touching_ghost) do
        has_eaten_all_dots and not lose?(power_pellet_active, touching_ghost)
      end
    end
  end
end

defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.PrivateHelperFunctions.SquareRootTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.SquareRoot

  alias ElixirAnalyzer.Constants

  test_exercise_analysis "solution with private helpers",
    comments: [] do
    defmodule SquareRoot do
      defguardp is_positive(n) when n >= 0

      defmacrop unless_equal_to(guess, goal, do: expr) do
        quote do
          if unquote(guess) == unquote(goal) do
            unquote(goal)
          else
            unquote(expr)
          end
        end
      end

      def calculate(1), do: 1

      def calculate(radicand) do
        guess = div(radicand, 2)
        do_calculate(radicand, guess)
      end

      defp do_calculate(radicand, guess) when is_positive(guess) do
        new_guess = div(guess + div(radicand, guess), 2)

        unless_equal_to new_guess, guess do
          do_calculate(radicand, new_guess)
        end
      end
    end
  end

  test_exercise_analysis "solution with public guard",
    comments: [Constants.solution_private_helper_functions()] do
    defmodule SquareRoot do
      defguard is_positive(n) when n >= 0

      defmacrop unless_equal_to(guess, goal, do: expr) do
        quote do
          if unquote(guess) == unquote(goal) do
            unquote(goal)
          else
            unquote(expr)
          end
        end
      end

      def calculate(1), do: 1

      def calculate(radicand) do
        guess = div(radicand, 2)
        do_calculate(radicand, guess)
      end

      defp do_calculate(radicand, guess) when is_positive(guess) do
        new_guess = div(guess + div(radicand, guess), 2)

        unless_equal_to new_guess, guess do
          do_calculate(radicand, new_guess)
        end
      end
    end
  end

  test_exercise_analysis "solution with public macro",
    comments: [Constants.solution_private_helper_functions()] do
    defmodule SquareRoot do
      defguardp is_positive(n) when n >= 0

      defmacro unless_equal_to(guess, goal, do: expr) do
        quote do
          if unquote(guess) == unquote(goal) do
            unquote(goal)
          else
            unquote(expr)
          end
        end
      end

      def calculate(1), do: 1

      def calculate(radicand) do
        guess = div(radicand, 2)
        do_calculate(radicand, guess)
      end

      defp do_calculate(radicand, guess) when is_positive(guess) do
        new_guess = div(guess + div(radicand, guess), 2)

        unless_equal_to new_guess, guess do
          do_calculate(radicand, new_guess)
        end
      end
    end
  end

  test_exercise_analysis "solution with public def",
    comments: [Constants.solution_private_helper_functions()] do
    defmodule SquareRoot do
      defguardp is_positive(n) when n >= 0

      defmacrop unless_equal_to(guess, goal, do: expr) do
        quote do
          if unquote(guess) == unquote(goal) do
            unquote(goal)
          else
            unquote(expr)
          end
        end
      end

      def calculate(1), do: 1

      def calculate(radicand) do
        guess = div(radicand, 2)
        do_calculate(radicand, guess)
      end

      def do_calculate(radicand, guess) when is_positive(guess) do
        new_guess = div(guess + div(radicand, guess), 2)

        unless_equal_to new_guess, guess do
          do_calculate(radicand, new_guess)
        end
      end
    end
  end
end
