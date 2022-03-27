defmodule ElixirAnalyzer.TestSuite.LasagnaTest do
  alias ElixirAnalyzer.Constants

  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.Lasagna

  test_exercise_analysis "example solution",
    comments: [Constants.solution_same_as_exemplar()] do
    defmodule Lasagna do
      def expected_minutes_in_oven() do
        40
      end

      def remaining_minutes_in_oven(actual_minutes_in_oven) do
        expected_minutes_in_oven() - actual_minutes_in_oven
      end

      def preparation_time_in_minutes(number_of_layers) do
        number_of_layers * 2
      end

      def total_time_in_minutes(number_of_layers, actual_minutes_in_oven) do
        preparation_time_in_minutes(number_of_layers) + actual_minutes_in_oven
      end

      def alarm() do
        "Ding!"
      end
    end
  end

  test_exercise_analysis "other reasonable solution",
    comments: [] do
    [
      defmodule Lasagna do
        def expected_minutes_in_oven() do
          40
        end

        def remaining_minutes_in_oven(actual) do
          expected_minutes_in_oven() - actual
        end

        def preparation_time_in_minutes(layers) do
          2 * layers
        end

        def total_time_in_minutes(layers, actual) do
          actual + preparation_time_in_minutes(layers)
        end

        def alarm() do
          "Ding!"
        end
      end,
      defmodule Lasagna do
        def expected_minutes_in_oven() do
          40
        end

        def remaining_minutes_in_oven(actual) do
          Lasagna.expected_minutes_in_oven() - actual
        end

        def preparation_time_in_minutes(layers) do
          2 * layers
        end

        def total_time_in_minutes(layers, actual) do
          actual + __MODULE__.preparation_time_in_minutes(layers)
        end

        def alarm() do
          "Ding!"
        end
      end
    ]
  end

  describe "function reuse" do
    test_exercise_analysis "Lasagna.remaining_minutes_in_oven must call expected_minutes_in_oven",
      comments_include: [Constants.lasagna_function_reuse()] do
      [
        defmodule WrongModuleName do
          def preparation_time_in_minutes(layers) do
            2 * layers
          end

          def total_time_in_minutes(layers, actual) do
            actual + preparation_time_in_minutes(layers)
          end
        end,
        defmodule Lasagna do
          def preparation_time_in_minutes(layers) do
            2 * layers
          end

          def total_time_in_minutes(layers, actual) do
            actual + 2 * layers
          end
        end
      ]
    end

    test_exercise_analysis "Lasagna.total_time_in_minutes must call preparation_time_in_minutes",
      comments_include: [Constants.lasagna_function_reuse()] do
      [
        defmodule WrongModuleName do
          def expected_minutes_in_oven() do
            40
          end

          def remaining_minutes_in_oven(actual_minutes_in_oven) do
            expected_minutes_in_oven() - actual_minutes_in_oven
          end
        end,
        defmodule Lasagna do
          def expected_minutes_in_oven() do
            40
          end

          def remaining_minutes_in_oven(actual_minutes_in_oven) do
            40 - actual_minutes_in_oven
          end
        end
      ]
    end
  end
end
