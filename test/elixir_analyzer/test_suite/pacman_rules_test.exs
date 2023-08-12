defmodule ElixirAnalyzer.ExerciseTest.PacmanRulesTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.PacmanRules

  test_exercise_analysis "example solution",
    comments: [ElixirAnalyzer.Constants.solution_same_as_exemplar()] do
    defmodule Rules do
      def eat_ghost?(power_pellet_active?, touching_ghost?) do
        power_pellet_active? and touching_ghost?
      end

      def score?(touching_power_pellet?, touching_dot?) do
        touching_power_pellet? or touching_dot?
      end

      def lose?(power_pellet_active?, touching_ghost?) do
        not power_pellet_active? and touching_ghost?
      end

      def win?(has_eaten_all_dots?, power_pellet_active?, touching_ghost?) do
        has_eaten_all_dots? and not lose?(power_pellet_active?, touching_ghost?)
      end
    end
  end

  describe "suggests strictly boolean operators" do
    test_exercise_analysis "detects &&",
      comments_include: [Constants.pacman_rules_use_strictly_boolean_operators()] do
      [
        defmodule Rules do
          def eat_ghost?(power_pellet_active?, touching_ghost?) do
            power_pellet_active? && touching_ghost?
          end
        end,
        defmodule Rules do
          def eat_ghost?(power_pellet_active?, touching_ghost?) do
            power_pellet_active? and touching_ghost?
          end

          def lose?(power_pellet_active?, touching_ghost?) do
            not power_pellet_active? && touching_ghost?
          end
        end,
        defmodule Rules do
          def eat_ghost?(power_pellet_active?, touching_ghost?) do
            Kernel.&&(power_pellet_active?, touching_ghost?)
          end
        end
      ]
    end

    test_exercise_analysis "detects ||",
      comments_include: [Constants.pacman_rules_use_strictly_boolean_operators()] do
      [
        defmodule Rules do
          def score?(touching_power_pellet?, touching_dot?) do
            touching_power_pellet? || touching_dot?
          end
        end,
        defmodule Rules do
          def score?(touching_power_pellet?, touching_dot?) do
            Kernel.||(touching_power_pellet?, touching_dot?)
          end
        end
      ]
    end

    test_exercise_analysis "detects !",
      comments_include: [Constants.pacman_rules_use_strictly_boolean_operators()] do
      [
        defmodule Rules do
          def lose?(power_pellet_active?, touching_ghost?) do
            !power_pellet_active? and touching_ghost?
          end
        end,
        defmodule Rules do
          def lose?(power_pellet_active?, touching_ghost?) do
            touching_ghost? and !power_pellet_active?
          end
        end,
        defmodule Rules do
          def lose?(power_pellet_active?, touching_ghost?) do
            not power_pellet_active? and touching_ghost?
          end

          def win?(has_eaten_all_dots?, power_pellet_active?, touching_ghost?) do
            has_eaten_all_dots? and !lose?(power_pellet_active?, touching_ghost?)
          end
        end,
        defmodule Rules do
          def eat_ghost?(power_pellet_active?, touching_ghost?) do
            !!power_pellet_active? and !!touching_ghost?
          end
        end,
        defmodule Rules do
          def lose?(power_pellet_active?, touching_ghost?) do
            Kernel.!(power_pellet_active?) and touching_ghost?
          end
        end
      ]
    end
  end
end
