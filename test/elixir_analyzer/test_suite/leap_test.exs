defmodule ElixirAnalyzer.TestSuite.LeapTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.Leap

  test_exercise_analysis "example solution",
    comments: [] do
    defmodule Year do
      def leap_year?(year) do
        div4?(year) && div100?(year) == div400?(year)
      end

      defp divides?(dividend, divisor), do: rem(dividend, divisor) == 0
      defp div4?(dividend), do: divides?(dividend, 4)
      defp div100?(dividend), do: divides?(dividend, 100)
      defp div400?(dividend), do: divides?(dividend, 400)
    end
  end

  test_exercise_analysis "forbids usage of :calendar Erlang module",
    comments_include: [Constants.leap_erlang_calendar()] do
    [
      defmodule Year do
        def leap_year?(year) do
          :calendar.is_leap_year(year)
        end
      end,
      defmodule Year do
        import :calendar

        def leap_year?(year) do
          is_leap_year(year)
        end
      end,
      defmodule Year do
        alias :calendar, as: C

        def leap_year?(year) do
          C.is_leap_year(year)
        end
      end
    ]
  end
end
