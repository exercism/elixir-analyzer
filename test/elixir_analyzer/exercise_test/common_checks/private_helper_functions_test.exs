# credo:disable-for-this-file Credo.Check.Warning.UnusedEnumOperation

defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.PrivateHelperFunctionsTest do
  use ExUnit.Case

  alias ElixirAnalyzer.ExerciseTest.CommonChecks.PrivateHelperFunctions
  alias ElixirAnalyzer.Comment
  alias ElixirAnalyzer.Constants

  @pacman_exemplar "elixir/exercises/concept/pacman-rules/.meta/exemplar.ex"
                   |> File.read!()
                   |> Code.string_to_quoted()

  @sqrt_example "elixir/exercises/practice/square-root/.meta/example.ex"
                |> File.read!()
                |> Code.string_to_quoted()

  @poker_example "elixir/exercises/practice/poker/.meta/example.ex"
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

      assert PrivateHelperFunctions.run(code, @pacman_exemplar) == []
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
        | params: %{actual: "defguard is_bool(_)", expected: "defguardp is_bool(_)"}
      }

      assert PrivateHelperFunctions.run(code, @pacman_exemplar) == [{:fail, comment}]
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
        | params: %{actual: "defmacro super_and(_, _)", expected: "defmacrop super_and(_, _)"}
      }

      assert PrivateHelperFunctions.run(code, @pacman_exemplar) == [{:fail, comment}]
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
        | params: %{actual: "def do_or(_, _)", expected: "defp do_or(_, _)"}
      }

      assert PrivateHelperFunctions.run(code, @pacman_exemplar) == [{:fail, comment}]
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
        | params: %{actual: "defguard is_bool(_)", expected: "defguardp is_bool(_)"}
      }

      assert PrivateHelperFunctions.run(code, @pacman_exemplar) == [{:fail, comment}]
    end

    test "submodules are not included" do
      code =
        quote do
          defmodule Rules do
            defmodule BooleanLogic do
              def do_or(left, right), do: left or right
            end

            def score?(touching_power_pellet, touching_dot) do
              BooleanLogic.do_or(touching_power_pellet, touching_dot)
            end
          end
        end

      assert PrivateHelperFunctions.run(code, @pacman_exemplar) == []
    end

    test "modules other than the main one are not included" do
      code =
        quote do
          defmodule BooleanLogic do
            def do_or(left, right), do: left or right
          end

          defmodule Rules do
            defmodule EmptyModule do
            end

            def score?(touching_power_pellet, touching_dot) do
              BooleanLogic.do_or(touching_power_pellet, touching_dot)
            end
          end
        end

      assert PrivateHelperFunctions.run(code, @pacman_exemplar) == []
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

      assert PrivateHelperFunctions.run(code, @sqrt_example) == []
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
        | params: %{actual: "defguard is_positive(_)", expected: "defguardp is_positive(_)"}
      }

      assert PrivateHelperFunctions.run(code, @sqrt_example) == [{:fail, comment}]
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
            actual: "defmacro unless_equal_to(_, _, _)",
            expected: "defmacrop unless_equal_to(_, _, _)"
          }
      }

      assert PrivateHelperFunctions.run(code, @sqrt_example) == [{:fail, comment}]
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
        | params: %{actual: "def do_calculate(_, _)", expected: "defp do_calculate(_, _)"}
      }

      assert PrivateHelperFunctions.run(code, @sqrt_example) == [{:fail, comment}]
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
        | params: %{actual: "def calculate(_, _)", expected: "defp calculate(_, _)"}
      }

      assert PrivateHelperFunctions.run(code, @sqrt_example) == [{:fail, comment}]
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
        | params: %{actual: "def calculate(_, _)", expected: "defp calculate(_, _)"}
      }

      assert PrivateHelperFunctions.run(code, @sqrt_example) == [{:fail, comment}]
    end
  end

  @remote_control_car_exemplar (quote do
                                  defmodule RemoteControlCar do
                                    def new(nickname \\ "none") do
                                      %RemoteControlCar{nickname: nickname}
                                    end
                                  end
                                end)

  describe "concept exercise with remote-control-car" do
    test "new with no argument" do
      code =
        quote do
          defmodule RemoteControlCar do
            def new(), do: %RemoteControlCar{nickname: "none"}
          end
        end

      assert PrivateHelperFunctions.run(code, @remote_control_car_exemplar) == []
    end

    test "new with one argument" do
      code =
        quote do
          defmodule RemoteControlCar do
            def new(name), do: %RemoteControlCar{nickname: name}
          end
        end

      assert PrivateHelperFunctions.run(code, @remote_control_car_exemplar) == []
    end

    test "new with zero and one argument" do
      code =
        quote do
          defmodule RemoteControlCar do
            def new(), do: %RemoteControlCar{nickname: "none"}
            def new(name), do: %RemoteControlCar{nickname: name}
          end
        end

      assert PrivateHelperFunctions.run(code, @remote_control_car_exemplar) == []
    end

    test "new with default argument" do
      code =
        quote do
          defmodule RemoteControlCar do
            def new(name \\ "none"), do: %RemoteControlCar{nickname: name}
          end
        end

      assert PrivateHelperFunctions.run(code, @remote_control_car_exemplar) == []
    end

    test "new with default argument head" do
      code =
        quote do
          defmodule RemoteControlCar do
            def new(name \\ "none")
            def new(name), do: %RemoteControlCar{nickname: name}
          end
        end

      assert PrivateHelperFunctions.run(code, @remote_control_car_exemplar) == []
    end

    test "new with two arguments" do
      code =
        quote do
          defmodule RemoteControlCar do
            def new(arg, name)
          end
        end

      comment = %{
        @comment
        | params: %{actual: "def new(_, _)", expected: "defp new(_, _)"}
      }

      assert PrivateHelperFunctions.run(code, @remote_control_car_exemplar) == [{:fail, comment}]
    end

    test "new with three default arguments gives a comment on arity 2" do
      code =
        quote do
          defmodule RemoteControlCar do
            def new(arg \\ 0, name \\ "none", extra \\ 1)
          end
        end

      comment = %{
        @comment
        | params: %{actual: "def new(_, _)", expected: "defp new(_, _)"}
      }

      assert PrivateHelperFunctions.run(code, @remote_control_car_exemplar) == [{:fail, comment}]
    end
  end

  describe "practice exercise with poker" do
    test "allows a compare/2 function for Enum.sort/2" do
      code =
        quote do
          defmodule Poker do
            def best_hand(hands) do
              Enum.sort(hands, Poker)
            end

            @ranks ~w(2 3 4 5 6 7 8 9 10 J Q K A)
            defp index_of({_, rank}), do: index_of(rank)
            defp index_of(rank), do: Enum.find_index(@ranks, &(&1 == rank))

            def compare({_, first_rank}, {_, second_rank}) do
              cond do
                first_rank == second_rank -> :eq
                index_of(first_rank) > index_of(second_rank) -> :gt
                true -> :lt
              end
            end
          end
        end

      assert PrivateHelperFunctions.run(code, @poker_example) == []
    end

    test "allows a compare/2 function for Enum.sort/2 desc" do
      code =
        quote do
          defmodule Poker do
            def best_hand(hands) do
              Enum.sort(hands, {:desc, Poker})
            end

            @ranks ~w(2 3 4 5 6 7 8 9 10 J Q K A)
            defp index_of({_, rank}), do: index_of(rank)
            defp index_of(rank), do: Enum.find_index(@ranks, &(&1 == rank))

            def compare({_, first_rank}, {_, second_rank}) do
              cond do
                first_rank == second_rank -> :eq
                index_of(first_rank) > index_of(second_rank) -> :gt
                true -> :lt
              end
            end
          end
        end

      assert PrivateHelperFunctions.run(code, @poker_example) == []
    end

    test "allows a compare/2 function for Enum.sort/2 with __MODULE__" do
      code =
        quote do
          defmodule Poker do
            def best_hand(hands) do
              Enum.sort(hands, __MODULE__)
            end

            @ranks ~w(2 3 4 5 6 7 8 9 10 J Q K A)
            defp index_of({_, rank}), do: index_of(rank)
            defp index_of(rank), do: Enum.find_index(@ranks, &(&1 == rank))

            def compare({_, first_rank}, {_, second_rank}) do
              cond do
                first_rank == second_rank -> :eq
                index_of(first_rank) > index_of(second_rank) -> :gt
                true -> :lt
              end
            end
          end
        end

      assert PrivateHelperFunctions.run(code, @poker_example) == []
    end

    test "allows a compare/2 function for Enum.sort/2 with piping" do
      code =
        quote do
          defmodule Poker do
            def best_hand(hands) do
              hands |> Enum.sort(Poker)
            end

            @ranks ~w(2 3 4 5 6 7 8 9 10 J Q K A)
            defp index_of({_, rank}), do: index_of(rank)
            defp index_of(rank), do: Enum.find_index(@ranks, &(&1 == rank))

            def compare({_, first_rank}, {_, second_rank}) do
              cond do
                first_rank == second_rank -> :eq
                index_of(first_rank) > index_of(second_rank) -> :gt
                true -> :lt
              end
            end
          end
        end

      assert PrivateHelperFunctions.run(code, @poker_example) == []
    end

    test "allows a compare/2 function for Enum.sort/2 with piping and __MODULE__" do
      code =
        quote do
          defmodule Poker do
            def best_hand(hands) do
              hands |> Enum.sort(__MODULE__)
            end

            @ranks ~w(2 3 4 5 6 7 8 9 10 J Q K A)
            defp index_of({_, rank}), do: index_of(rank)
            defp index_of(rank), do: Enum.find_index(@ranks, &(&1 == rank))

            def compare({_, first_rank}, {_, second_rank}) do
              cond do
                first_rank == second_rank -> :eq
                index_of(first_rank) > index_of(second_rank) -> :gt
                true -> :lt
              end
            end
          end
        end

      assert PrivateHelperFunctions.run(code, @poker_example) == []
    end

    test "allows a compare/2 function for Enum.sort_by/3" do
      code =
        quote do
          defmodule Poker do
            def best_hand(hands) do
              Enum.sort_by(hands, & &1, Poker)
            end

            @ranks ~w(2 3 4 5 6 7 8 9 10 J Q K A)
            defp index_of({_, rank}), do: index_of(rank)
            defp index_of(rank), do: Enum.find_index(@ranks, &(&1 == rank))

            def compare({_, first_rank}, {_, second_rank}) do
              cond do
                first_rank == second_rank -> :eq
                index_of(first_rank) > index_of(second_rank) -> :gt
                true -> :lt
              end
            end
          end
        end

      assert PrivateHelperFunctions.run(code, @poker_example) == []
    end

    test "allows a compare/2 function for Enum.sort_by/3 with piping" do
      code =
        quote do
          defmodule Poker do
            def best_hand(hands) do
              hands |> Enum.sort_by(& &1, Poker)
            end

            @ranks ~w(2 3 4 5 6 7 8 9 10 J Q K A)
            defp index_of({_, rank}), do: index_of(rank)
            defp index_of(rank), do: Enum.find_index(@ranks, &(&1 == rank))

            def compare({_, first_rank}, {_, second_rank}) do
              cond do
                first_rank == second_rank -> :eq
                index_of(first_rank) > index_of(second_rank) -> :gt
                true -> :lt
              end
            end
          end
        end

      assert PrivateHelperFunctions.run(code, @poker_example) == []
    end

    test "allows a compare/2 function for Enum.sort_by/3 with piping and __MODULE__" do
      code =
        quote do
          defmodule Poker do
            def best_hand(hands) do
              hands |> Enum.sort_by(& &1, __MODULE__)
            end

            @ranks ~w(2 3 4 5 6 7 8 9 10 J Q K A)
            defp index_of({_, rank}), do: index_of(rank)
            defp index_of(rank), do: Enum.find_index(@ranks, &(&1 == rank))

            def compare({_, first_rank}, {_, second_rank}) do
              cond do
                first_rank == second_rank -> :eq
                index_of(first_rank) > index_of(second_rank) -> :gt
                true -> :lt
              end
            end
          end
        end

      assert PrivateHelperFunctions.run(code, @poker_example) == []
    end

    test "compare must be of arity 2" do
      code =
        quote do
          defmodule Poker do
            def best_hand(hands) do
              hands |> Enum.sort(__MODULE__)
            end

            @ranks ~w(2 3 4 5 6 7 8 9 10 J Q K A)
            defp index_of({_, rank}), do: index_of(rank)
            defp index_of(rank), do: Enum.find_index(@ranks, &(&1 == rank))

            def compare({_, first_rank}, {_, second_rank}, opts \\ []) do
              cond do
                first_rank == second_rank -> :eq
                index_of(first_rank) > index_of(second_rank) -> :gt
                true -> :lt
              end
            end
          end
        end

      comment = %{
        @comment
        | params: %{actual: "def compare(_, _, _)", expected: "defp compare(_, _, _)"}
      }

      assert PrivateHelperFunctions.run(code, @poker_example) == [{:fail, comment}]
    end

    test "doesn't allow a compare/2 function when not used" do
      code =
        quote do
          defmodule Poker do
            def best_hand(hands) do
              Enum.sort(hands)
              Enum.sort_by(hands, & &1)

              Enum.sort(hands, :desc)
              Enum.sort_by(hands, & &1, :desc)

              Enum.sort(hands, {:asc, Poker.InnerModule})
              Enum.sort_by(hands, & &1, {:asc, Poker.InnerModule})
            end

            @ranks ~w(2 3 4 5 6 7 8 9 10 J Q K A)
            defp index_of({_, rank}), do: index_of(rank)
            defp index_of(rank), do: Enum.find_index(@ranks, &(&1 == rank))

            def compare({_, first_rank}, {_, second_rank}) do
              cond do
                first_rank == second_rank -> :eq
                index_of(first_rank) > index_of(second_rank) -> :gt
                true -> :lt
              end
            end
          end
        end

      comment = %{
        @comment
        | params: %{actual: "def compare(_, _)", expected: "defp compare(_, _)"}
      }

      assert PrivateHelperFunctions.run(code, @poker_example) == [{:fail, comment}]
    end
  end
end
