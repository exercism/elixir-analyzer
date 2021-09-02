defmodule ElixirAnalyzer.ExerciseTest.ChessboardTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.Chessboard

  test_exercise_analysis "example solution",
    comments: [] do
    defmodule Chessboard do
      def rank_range do
        1..8
      end

      def file_range do
        ?A..?H
      end

      def ranks do
        Enum.to_list(rank_range())
      end

      def files do
        Enum.map(file_range(), &<<&1>>)
      end
    end
  end

  describe "function reuse" do
    test_exercise_analysis "detects lack of reuse in both cases",
      comments_include: [Constants.chessboard_function_reuse()] do
      [
        defmodule Chessboard do
          def rank_range do
            1..8
          end

          def file_range do
            ?A..?H
          end

          def ranks do
            Enum.to_list(1..8)
          end

          def files do
            Enum.map(file_range(), &<<&1>>)
          end
        end,
        defmodule Chessboard do
          def rank_range do
            1..8
          end

          def file_range do
            ?A..?H
          end

          def ranks do
            Enum.to_list(rank_range())
          end

          def files do
            Enum.map(?A..?H, &<<&1>>)
          end
        end,
        defmodule Chessboard do
          def rank_range do
            1..8
          end

          def file_range do
            ?A..?H
          end

          def ranks do
            Enum.to_list(1..8)
          end

          def files do
            Enum.map(?A..?H, &<<&1>>)
          end
        end
      ]
    end
  end

  describe "creating a string from a codepoint" do
    test_exercise_analysis "detects going around by changing to a charlist first",
      comments_include: [Constants.chessboard_change_codepoint_to_string_directly()] do
      [
        defmodule Chessboard do
          def files do
            Enum.map(file_range(), &to_string([&1]))
          end
        end,
        def files do
          Enum.map(file_range(), &List.to_string([&1]))
        end
      ]
    end

    test_exercise_analysis "allows all kinds of ways of using <<>>",
      comments_exclude: [Constants.chessboard_change_codepoint_to_string_directly()] do
      # it's a special form so &Kernel.<<>>/1 doesn't work
      [
        defmodule Chessboard do
          def files do
            Enum.map(file_range(), &<<&1>>)
          end
        end,
        defmodule Chessboard do
          def files do
            Enum.map(file_range(), fn codepoint -> <<codepoint>> end)
          end
        end
      ]
    end
  end
end
