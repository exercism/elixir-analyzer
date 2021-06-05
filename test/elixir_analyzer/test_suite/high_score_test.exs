defmodule ElixirAnalyzer.ExerciseTest.HighScoreTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.HighScore

  test_exercise_analysis "example solution",
    comments: [] do
    defmodule HighScore do
      @initial_score 0

      def new(), do: %{}

      def add_player(scores, name, score \\ @initial_score) do
        Map.put(scores, name, score)
      end

      def remove_player(scores, name) do
        Map.delete(scores, name)
      end

      def reset_score(scores, name) do
        Map.put(scores, name, @initial_score)
      end

      def update_score(scores, name, score) do
        Map.update(scores, name, score, &(&1 + score))
      end

      def get_players(scores) do
        Map.keys(scores)
      end
    end
  end

  describe "looks for a module attribute with the initial score of 0" do
    test_exercise_analysis "only the value must match",
      comments_exclude: [Constants.high_score_use_module_attribute()] do
      [
        def HighScore do
          @initial_score 0

          def add_player(scores, name, score \\ @initial_score) do
            Map.put(scores, name, score)
          end

          def reset_score(scores, name) do
            Map.put(scores, name, @initial_score)
          end
        end,
        def HighScore do
          @initial_score 0

          def add_player(scores, name) do
            x = @initial_score
            Map.put_new(scores, name, x)
          end

          def add_player(scores, name, score) do
            Map.put_new(scores, name, score)
          end

          def reset_score(scores, name) do
            Map.update(scores, name, @initial_score, fn _ -> @initial_score end)
          end
        end,
        def HighScore do
          @init 0

          def add_player(scores, name, score \\ @init) do
            Map.put(scores, name, score)
          end

          def reset_score(scores, name) do
            Map.put(scores, name, @init)
          end
        end,
        defmodule HighScore do
          def new(), do: %{}

          @score 0
          def add_player(scores, name, score \\ @score) do
            Map.put(scores, name, score)
          end

          def reset_score(scores, name) do
            Map.put(scores, name, @score)
          end
        end
      ]
    end

    test_exercise_analysis "missing, not used, or wrong value",
      comments: [Constants.high_score_use_module_attribute()] do
      [
        defmodule HighScore do
          def new(), do: %{}

          def add_player(scores, name, score \\ 0) do
            Map.put(scores, name, score)
          end

          def reset_score(scores, name) do
            Map.put(scores, name, 0)
          end
        end,
        def HighScore do
          @initial_score 3

          def new(), do: %{}

          def add_player(scores, name, score \\ @initial_score) do
            Map.put(scores, name, score)
          end

          def reset_score(scores, name) do
            Map.put(scores, name, @initial_score)
          end
        end,
        def HighScore do
          @initial_score 0

          def new(), do: %{}

          def add_player(scores, name, score \\ 0) do
            Map.put(scores, name, score)
          end

          def reset_score(scores, name) do
            Map.put(scores, name, 0)
          end
        end,
        def HighScore do
          @initial_score 0

          def new(), do: %{}

          def add_player(scores, name, score \\ @initial_score) do
            Map.put(scores, name, score)
          end

          def reset_score(scores, name) do
            Map.put(scores, name, 0)
          end
        end,
        def HighScore do
          @initial_score 0

          def new(), do: %{}

          def add_player(scores, name, score) do
            Map.put(scores, name, score)
          end

          def reset_score(scores, name) do
            Map.put(scores, name, @initial_score)
          end
        end
      ]
    end
  end
end
