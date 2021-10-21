defmodule ElixirAnalyzer.TestSuite.LibraryFeesTest do
  alias ElixirAnalyzer.Constants

  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.LibraryFees

  test_exercise_analysis "example solution",
    comments: [Constants.solution_same_as_exemplar()] do
    defmodule LibraryFees do
      def datetime_from_string(string) do
        NaiveDateTime.from_iso8601!(string)
      end

      def before_noon?(datetime) do
        Time.compare(NaiveDateTime.to_time(datetime), ~T[12:00:00]) == :lt
      end

      def return_date(checkout_datetime) do
        days = if before_noon?(checkout_datetime), do: 28, else: 29
        datetime = NaiveDateTime.add(checkout_datetime, days * 24 * 60 * 60, :second)
        NaiveDateTime.to_date(datetime)
      end

      def days_late(planned_return_date, actual_return_datetime) do
        diff =
          Date.diff(
            NaiveDateTime.to_date(actual_return_datetime),
            planned_return_date
          )

        if diff < 0, do: 0, else: diff
      end

      def monday?(datetime) do
        datetime
        |> NaiveDateTime.to_date()
        |> Date.day_of_week()
        |> Kernel.==(1)
      end

      def calculate_late_fee(checkout, return, rate) do
        checkout_datetime = datetime_from_string(checkout)
        planned_return_date = return_date(checkout_datetime)
        actual_return_datetime = datetime_from_string(return)

        days_late = days_late(planned_return_date, actual_return_datetime)
        rate = if monday?(actual_return_datetime), do: 0.5 * rate, else: rate
        trunc(days_late * rate)
      end
    end
  end

  test_exercise_analysis "other valid solution",
    comments: [] do
    # https://exercism.org/tracks/elixir/exercises/library-fees/solutions/BrightOne
    defmodule LibraryFees do
      def datetime_from_string(string) do
        {:ok, datetime} = NaiveDateTime.from_iso8601(string)
        datetime
      end

      def before_noon?(datetime) do
        datetime
        |> NaiveDateTime.to_time()
        |> Time.compare(~T[12:00:00]) == :lt
      end

      def return_date(checkout_datetime) do
        checkout_datetime
        |> NaiveDateTime.to_date()
        |> Date.add(if before_noon?(checkout_datetime), do: 28, else: 29)
      end

      def days_late(planned_return_date, actual_return_datetime) do
        actual_return_datetime
        |> NaiveDateTime.to_date()
        |> Date.diff(planned_return_date)
        |> max(0)
      end

      def monday?(datetime) do
        datetime
        |> NaiveDateTime.to_date()
        |> Date.day_of_week() == 1
      end

      def calculate_late_fee(checkout, return, rate) do
        checkout_datetime = datetime_from_string(checkout)
        actual_return_datetime = datetime_from_string(return)
        planned_return_date = return_date(checkout_datetime)
        days_late = days_late(planned_return_date, actual_return_datetime)
        late_fee = rate * days_late
        if monday?(actual_return_datetime), do: div(late_fee, 2), else: late_fee
      end
    end
  end

  describe "function reuse" do
    test_exercise_analysis "LibraryFees.calculate_late_fee must call datetime_from_string",
      comments_include: [Constants.library_fees_function_reuse()] do
      defmodule LibraryFees do
        def calculate_late_fee(checkout, return, rate) do
          checkout_datetime = NaiveDateTime.from_iso8601!(string)
          actual_return_datetime = NaiveDateTime.from_iso8601!(return)

          planned_return_date = return_date(checkout_datetime)
          days_late = days_late(planned_return_date, actual_return_datetime)
          rate = if monday?(actual_return_datetime), do: 0.5 * rate, else: rate
          trunc(days_late * rate)
        end
      end
    end

    test_exercise_analysis "LibraryFees.calculate_late_fee must call return_date",
      comments_include: [Constants.library_fees_function_reuse()] do
      defmodule LibraryFees do
        def calculate_late_fee(checkout, return, rate) do
          checkout_datetime = NaiveDateTime.from_iso8601!(string)

          days = if before_noon?(checkout_datetime), do: 28, else: 29
          datetime = NaiveDateTime.add(checkout_datetime, days * 24 * 60 * 60, :second)
          planned_return_date = NaiveDateTime.to_date(datetime)

          actual_return_datetime = datetime_from_string(return)
          days_late = days_late(planned_return_date, actual_return_datetime)
          rate = if monday?(actual_return_datetime), do: 0.5 * rate, else: rate
          trunc(days_late * rate)
        end
      end
    end

    test_exercise_analysis "LibraryFees.calculate_late_fee must call days_late",
      comments_include: [Constants.library_fees_function_reuse()] do
      defmodule LibraryFees do
        def calculate_late_fee(checkout, return, rate) do
          checkout_datetime = datetime_from_string(checkout)
          planned_return_date = return_date(checkout_datetime)
          actual_return_datetime = datetime_from_string(return)

          diff =
            Date.diff(
              NaiveDateTime.to_date(actual_return_datetime),
              planned_return_date
            )

          # using days_late as a binding here breaks assert_call
          days_late_count = if diff < 0, do: 0, else: diff

          rate = if monday?(actual_return_datetime), do: 0.5 * rate, else: rate
          trunc(days_late_count * rate)
        end
      end
    end

    test_exercise_analysis "LibraryFees.calculate_late_fee must call monday?",
      comments_include: [Constants.library_fees_function_reuse()] do
      defmodule LibraryFees do
        def calculate_late_fee(checkout, return, rate) do
          checkout_datetime = datetime_from_string(checkout)
          planned_return_date = return_date(checkout_datetime)
          actual_return_datetime = datetime_from_string(return)
          days_late = days_late(planned_return_date, actual_return_datetime)

          monday =
            actual_return_datetime
            |> NaiveDateTime.to_date()
            |> Date.day_of_week()
            |> Kernel.==(1)

          rate = if monday, do: 0.5 * rate, else: rate
          trunc(days_late * rate)
        end
      end
    end
  end
end
