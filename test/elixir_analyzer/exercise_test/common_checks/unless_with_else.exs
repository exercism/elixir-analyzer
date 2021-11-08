defmodule ElixirAnalyzer.Support.AnalyzerVerification.UnlessWithElse do
  use ElixirAnalyzer.ExerciseTest
end

defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.UnlessWithElseTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.Support.AnalyzerVerification.UnlessWithElse

  alias ElixirAnalyzer.Constants

  test_exercise_analysis "solutions which do not use unless/else", comments: [] do
    [
      defmodule MyModule do
        def unless_simple() do
          unless true do
            :error
          end
        end

        def unless_simple_keyword_list() do
          unless true, do: :error
        end

        def if_else() do
          if true do
            :ok
          else
            :error
          end
        end

        def if_else_keyword_list() do
          if true, do: :ok, else: :error
        end
      end
    ]
  end

  test_exercise_analysis "solutions which use unless/else",
    comments: [Constants.solution_unless_with_else()] do
    [
      defmodule MyModule do
        def unless_else() do
          unless true do
            :error
          else
            :ok
          end
        end
      end,
      defmodule MyModule do
        def unless_else_keyword_list() do
          unless true, do: :error, else: :ok
        end
      end
    ]
  end
end
