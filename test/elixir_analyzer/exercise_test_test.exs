defmodule ElixirAnalyzer.ExerciseTestTest.SameComment do
  use ElixirAnalyzer.ExerciseTest

  assert_no_call "essential comment for helper1_essential" do
    type :essential
    called_fn name: :helper1_essential
    comment "the same comment"
  end

  assert_no_call "essential comment for helper2_essential" do
    type :essential
    called_fn name: :helper2_essential
    comment "the same comment"
  end

  assert_no_call "actionable comment for helper3_actionable" do
    type :actionable
    called_fn name: :helper3_actionable
    comment "the same comment"
  end

  assert_no_call "different actionable comment for helper4_actionable_different" do
    type :actionable
    called_fn name: :helper4_actionable_different
    comment "different comment"
  end

  feature "essential comment for alias" do
    type :essential
    find :none
    comment "the same comment"

    form do
      alias Essential
    end
  end

  feature "actionable comment for import" do
    type :actionable
    find :none
    comment "the same comment"

    form do
      import Actionable
    end
  end
end

defmodule ElixirAnalyzer.ExerciseTestTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.ExerciseTestTest.SameComment

  describe "comment de-duplication" do
    test_exercise_analysis "doesn't include the same comment of the same type twice",
      comments: ["the same comment"] do
      [
        defmodule SomeModule do
          def function() do
            helper1_essential()
            helper2_essential()
          end
        end,
        defmodule SomeModule do
          alias Essential

          def function() do
            helper1_essential()
            helper2_essential()
          end
        end,
        defmodule SomeModule do
          import Actionable

          def function() do
            helper3_actionable()
          end
        end
      ]
    end

    test_exercise_analysis "includes the same comment twice if it has different types",
      comments: ["the same comment", "the same comment"] do
      [
        defmodule SomeModule do
          def function() do
            helper1_essential()
            helper2_essential()
            helper3_actionable()
          end
        end,
        defmodule SomeModule do
          def function() do
            helper1_essential()
            helper3_actionable()
          end
        end,
        defmodule SomeModule do
          import Actionable

          def function() do
            helper1_essential()
          end
        end,
        defmodule SomeModule do
          alias Essential

          def function() do
            helper3_actionable()
          end
        end
      ]
    end

    test_exercise_analysis "doesn't remove different comments of the same type",
      comments: ["the same comment", "different comment"] do
      [
        defmodule SomeModule do
          def function() do
            helper3_actionable()
            helper4_actionable_different()
          end
        end
      ]
    end
  end
end
