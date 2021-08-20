defmodule ElixirAnalyzer.ExerciseTest.CommentOrderTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.Support.AnalyzerVerification.CommentOrder,
    unsorted_comments: true

  test_exercise_analysis "triggering module",
    # Comments in order of importance
    comments: ["essential", "actionable", "informative", "celebratory"] do
    defmodule TriggeringtModule do
      def foo() do
        :celebratory
      end
    end
  end
end
