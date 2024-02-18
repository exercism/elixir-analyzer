defmodule ElixirAnalyzer.ExerciseTest.HighScoreTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.HighScore

  test_exercise_analysis "example solution",
    comments: [ElixirAnalyzer.Constants.solution_same_as_exemplar()] do
    [
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
    ]
  end

  test_exercise_analysis "other solutions",
    comments: [] do
    [
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
          scores |> remove_player(name) |> add_player(name)
        end

        def update_score(scores, name, score) do
          Map.update(scores, name, score, &(&1 + score))
        end

        def get_players(scores) do
          Map.keys(scores)
        end
      end,
      defmodule HighScore do
        @default_score 0

        def new(), do: %{}

        defdelegate add_player(scores, name, score \\ @default_score), to: Map, as: :put

        defdelegate remove_player(scores, name), to: Map, as: :delete

        def reset_score(scores, name), do: Map.put(scores, name, @default_score)

        def update_score(scores, name, score),
          do: Map.update(scores, name, score, fn x -> x + score end)

        defdelegate get_players(scores), to: Map, as: :keys
      end
    ]
  end

  test_exercise_analysis "other solutions with rescue",
    comments: [ElixirAnalyzer.Constants.solution_no_rescue()] do
    [
      defmodule HighScore do
        @initial_score 0

        def new(), do: %{}

        def add_player(scores, name, score \\ @initial_score) do
          Map.put(scores, name, score)
        end

        def remove_player(scores, name) do
          Map.delete(scores, name)
        rescue
          _ -> "this is completely unnecessary"
        end

        def reset_score(scores, name) do
          scores |> remove_player(name) |> add_player(name)
        rescue
          _ -> "this is completely unnecessary"
        end

        def update_score(scores, name, score) do
          Map.update(scores, name, score, &(&1 + score))
        rescue
          _ -> "this is completely unnecessary"
        end

        def get_players(scores) do
          Map.keys(scores)
        rescue
          _ -> "this is completely unnecessary"
        end
      end
    ]
  end

  describe "add_player and default argument" do
    test_exercise_analysis "requires add_player to have a default argument that's a module attribute",
      comments_include: [Constants.high_score_use_default_argument_with_module_attribute()] do
      [
        defmodule HighScore do
          def add_player(scores, name) do
            Map.put(scores, name, @any_name)
          end

          def add_player(scores, name, score) do
            Map.put(scores, name, score)
          end
        end,
        defmodule HighScore do
          def add_player(scores, name, score \\ nil) do
            score = score || @initial_score
            Map.put(scores, name, score)
          end
        end,
        defmodule HighScore do
          def add_player(scores, name, score \\ 0) do
            Map.put(scores, name, score)
          end
        end
      ]
    end

    test_exercise_analysis "accepts an empty function head",
      comments_exclude: [Constants.high_score_use_default_argument_with_module_attribute()] do
      defmodule HighScore do
        def new(), do: %{}

        @score 0
        def add_player(scores, name, score \\ @score)

        def add_player(scores, name, score) do
          Map.put(scores, name, score)
        end

        def reset_score(scores, name) do
          Map.put(scores, name, @score)
        end
      end
    end

    test_exercise_analysis "accepts a guard",
      comments_exclude: [Constants.high_score_use_default_argument_with_module_attribute()] do
      defmodule HighScore do
        def new(), do: %{}

        @score 0
        def add_player(scores, name, score \\ @score) when is_bitstring(name) do
          Map.put(scores, name, score)
        end

        def reset_score(scores, name) do
          Map.put(scores, name, @score)
        end
      end
    end

    test_exercise_analysis "accepts an empty function head with a guard",
      comments_exclude: [Constants.high_score_use_default_argument_with_module_attribute()] do
      defmodule HighScore do
        def new(), do: %{}

        @score 0
        def add_player(scores, name, score \\ @score) when is_bitstring(name)

        def add_player(scores, name, score) do
          Map.put(scores, name, score)
        end

        def reset_score(scores, name) do
          Map.put(scores, name, @score)
        end
      end
    end
  end

  describe "looks for a module attribute with the initial score of 0" do
    test_exercise_analysis "only the value must match",
      comments_exclude: [Constants.high_score_use_module_attribute()] do
      [
        defmodule HighScore do
          @initial_score 0

          def add_player(scores, name, score \\ @initial_score) do
            Map.put(scores, name, score)
          end

          def reset_score(scores, name) do
            Map.put(scores, name, @initial_score)
          end
        end,
        defmodule HighScore do
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
        defmodule HighScore do
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
      comments_include: [Constants.high_score_use_module_attribute()] do
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
        defmodule HighScore do
          @initial_score 3

          def new(), do: %{}

          def add_player(scores, name, score \\ @initial_score) do
            Map.put(scores, name, score)
          end

          def reset_score(scores, name) do
            Map.put(scores, name, @initial_score)
          end
        end,
        defmodule HighScore do
          @initial_score 0

          def new(), do: %{}

          def add_player(scores, name, score \\ 0) do
            Map.put(scores, name, score)
          end

          def reset_score(scores, name) do
            Map.put(scores, name, 0)
          end
        end,
        defmodule HighScore do
          @initial_score 0

          def new(), do: %{}

          def add_player(scores, name, score \\ @initial_score) do
            Map.put(scores, name, score)
          end

          def reset_score(scores, name) do
            Map.put(scores, name, 0)
          end
        end
      ]
    end

    test_exercise_analysis "Map.update/4 not used in update_score",
      comments_include: [Constants.high_score_use_map_update()] do
      [
        defmodule HighScore do
          def update_score(scores, name, score) do
            Map.put(scores, name, Map.get(scores, name) + 1)
          end
        end
      ]
    end
  end
end
