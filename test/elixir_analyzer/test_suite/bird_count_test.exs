defmodule ElixirAnalyzer.ExerciseTest.BirdCountTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.BirdCount

  test_exercise_analysis "example solution",
    comments: [] do
    defmodule BirdCount do
      def today([]), do: nil
      def today([head | _]), do: head

      def increment_day_count([]), do: [1]
      def increment_day_count([head | tail]), do: [head + 1 | tail]

      def has_day_without_birds?([]), do: false
      def has_day_without_birds?([0 | _]), do: true
      def has_day_without_birds?([_ | tail]), do: has_day_without_birds?(tail)

      def total([]), do: 0
      def total([head | tail]), do: head + total(tail)

      def busy_days([]), do: 0
      def busy_days([head | tail]) when head >= 5, do: busy_days(tail) + 1
      def busy_days([_ | tail]), do: busy_days(tail)
    end
  end

  describe "forbids any method of iteration other than recursion" do
    test_exercise_analysis "detects Enum",
      comments_include: [Constants.bird_count_use_recursion()] do
      [
        defmodule BirdCount do
          def today(list), do: Enum.at(list, 0)
        end,
        defmodule BirdCount do
          def total(list), do: Enum.sum(list)
        end
      ]
    end

    # TOOD: detects List, Stream, and list comprehensions
  end
end
