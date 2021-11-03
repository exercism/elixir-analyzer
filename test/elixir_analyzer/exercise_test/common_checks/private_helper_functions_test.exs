defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.PrivateHelperFunctionsTest do
  use ExUnit.Case

  alias ElixirAnalyzer.ExerciseTest.CommonChecks.PrivateHelperFunctions
  alias ElixirAnalyzer.Comment
  alias ElixirAnalyzer.Constants

  @pacman_stub "elixir/exercises/concept/pacman-rules/lib/rules.ex"
               |> File.read!()
               |> Code.string_to_quoted()

  @sqrt_stub "elixir/exercises/practice/square-root/lib/square_root.ex"
             |> File.read!()
             |> Code.string_to_quoted()

  @comment %Comment{
    type: :informative,
    comment: Constants.solution_private_helper_functions(),
    name: Constants.solution_private_helper_functions()
  }

  describe "concept exercise with pacman-rules" do
    test "solution with private helpers" do
      code =
        quote do
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

      assert PrivateHelperFunctions.run(code, @pacman_stub) == []
    end

    test "solution with public guard" do
      code =
        quote do
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

      comment = %{
        @comment
        | params: %{actual: "defguard is_bool(a)", expected: "defguardp is_bool(a)"}
      }

      assert PrivateHelperFunctions.run(code, @pacman_stub) == [{:fail, comment}]
    end

    test "solution with public macro" do
      code =
        quote do
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

      comment = %{
        @comment
        | params: %{actual: "defmacro super_and(a, b)", expected: "defmacrop super_and(a, b)"}
      }

      assert PrivateHelperFunctions.run(code, @pacman_stub) == [{:fail, comment}]
    end

    test "solution with public def" do
      code =
        quote do
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

      comment = %{
        @comment
        | params: %{actual: "def do_or(a, b)", expected: "defp do_or(a, b)"}
      }

      assert PrivateHelperFunctions.run(code, @pacman_stub) == [{:fail, comment}]
    end

    test "only one comment will be shown" do
      code =
        quote do
          defmodule Rules do
            defguard is_bool(bool) when bool == true or bool == false

            defmacro super_and(left, right) do
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

      comment = %{
        @comment
        | params: %{actual: "def do_or(a, b)", expected: "defp do_or(a, b)"}
      }

      assert PrivateHelperFunctions.run(code, @pacman_stub) == [{:fail, comment}]
    end
  end

  describe "practice exercise with square-root" do
    test "solution with private helpers" do
      code =
        quote do
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

      assert PrivateHelperFunctions.run(code, @sqrt_stub) == []
    end

    test "solution with public guard" do
      code =
        quote do
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

      comment = %{
        @comment
        | params: %{actual: "defguard is_positive(a)", expected: "defguardp is_positive(a)"}
      }

      assert PrivateHelperFunctions.run(code, @sqrt_stub) == [{:fail, comment}]
    end

    test "solution with public macro" do
      code =
        quote do
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

      comment = %{
        @comment
        | params: %{
            actual: "defmacro unless_equal_to(a, b, c)",
            expected: "defmacrop unless_equal_to(a, b, c)"
          }
      }

      assert PrivateHelperFunctions.run(code, @sqrt_stub) == [{:fail, comment}]
    end

    test "solution with public def" do
      code =
        quote do
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

      comment = %{
        @comment
        | params: %{actual: "def do_calculate(a, b)", expected: "defp do_calculate(a, b)"}
      }

      assert PrivateHelperFunctions.run(code, @sqrt_stub) == [{:fail, comment}]
    end

    test "solution with different arity" do
      code =
        quote do
          defmodule SquareRoot do
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

            def calculate(radicand, guess) do
              new_guess = div(guess + div(radicand, guess), 2)

              unless_equal_to new_guess, guess do
                calculate(radicand, new_guess)
              end
            end
          end
        end

      comment = %{
        @comment
        | params: %{actual: "def calculate(a, b)", expected: "defp calculate(a, b)"}
      }

      assert PrivateHelperFunctions.run(code, @sqrt_stub) == [{:fail, comment}]
    end

    test "solution with different arity using when" do
      code =
        quote do
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

            def calculate(radicand, guess) when is_positive(guess) do
              new_guess = div(guess + div(radicand, guess), 2)

              unless_equal_to new_guess, guess do
                calculate(radicand, new_guess)
              end
            end
          end
        end

      comment = %{
        @comment
        | params: %{actual: "def calculate(a, b)", expected: "defp calculate(a, b)"}
      }

      assert PrivateHelperFunctions.run(code, @sqrt_stub) == [{:fail, comment}]
    end
  end
end
