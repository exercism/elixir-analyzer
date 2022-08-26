defmodule ElixirAnalyzer.TestSuite.NewPassportTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.NewPassport

  test_exercise_analysis "perfect solution",
    comments: [ElixirAnalyzer.Constants.solution_same_as_exemplar()] do
    defmodule NewPassport do
      def get_new_passport(now, birthday, form) do
        with {:ok, timestamp} <- enter_building(now),
             {:ok, manual} <- find_counter_information(now),
             counter <- manual.(birthday),
             {:ok, checksum} <- stamp_form(timestamp, counter, form) do
          {:ok, get_new_passport_number(timestamp, counter, checksum)}
        else
          {:coffee_break, _} ->
            {:retry, NaiveDateTime.add(now, 15 * 60, :second)}

          err ->
            err
        end
      end

      # Do not modify the functions below

      defp enter_building(%NaiveDateTime{} = datetime) do
        day = Date.day_of_week(datetime)
        time = NaiveDateTime.to_time(datetime)

        cond do
          day <= 4 and time_between(time, ~T[13:00:00], ~T[15:30:00]) ->
            {:ok, datetime |> DateTime.from_naive!("Etc/UTC") |> DateTime.to_unix()}

          day == 5 and time_between(time, ~T[13:00:00], ~T[14:30:00]) ->
            {:ok, datetime |> DateTime.from_naive!("Etc/UTC") |> DateTime.to_unix()}

          true ->
            {:error, "city office is closed"}
        end
      end

      @eighteen_years 18 * 365
      defp find_counter_information(%NaiveDateTime{} = datetime) do
        time = NaiveDateTime.to_time(datetime)

        if time_between(time, ~T[14:00:00], ~T[14:20:00]) do
          {:coffee_break, "information counter staff on coffee break, come back in 15 minutes"}
        else
          {:ok,
           fn %Date{} = birthday -> 1 + div(Date.diff(datetime, birthday), @eighteen_years) end}
        end
      end

      defp stamp_form(timestamp, counter, :blue) when rem(counter, 2) == 1 do
        {:ok, 3 * (timestamp + counter) + 1}
      end

      defp stamp_form(timestamp, counter, :red) when rem(counter, 2) == 0 do
        {:ok, div(timestamp + counter, 2)}
      end

      defp stamp_form(_timestamp, _counter, _form), do: {:error, "wrong form color"}

      defp get_new_passport_number(timestamp, counter, checksum) do
        "#{timestamp}-#{counter}-#{checksum}"
      end

      defp time_between(time, from, to) do
        Time.compare(from, time) != :gt and Time.compare(to, time) == :gt
      end
    end
  end

  test_exercise_analysis "does not use with in get_new_passport/3",
    comments_include: [Constants.new_passport_use_with()] do
    defmodule NewPassport do
      def get_new_passport(now, birthday, form) do
        case enter_building(now) do
          {:ok, timestamp} ->
            case find_counter_information(now) do
              {:ok, manual} ->
                counter = manual.(birthday)

                case stamp_form(timestamp, counter, form) do
                  {:ok, checksum} ->
                    {:ok, get_new_passport_number(timestamp, counter, checksum)}

                  err ->
                    err
                end

              {:coffee_break, _} ->
                {:retry, NaiveDateTime.add(now, 15 * 60, :second)}
            end

          err ->
            err
        end
      end
    end
  end

  test_exercise_analysis "modifies code",
    comments: [Constants.new_passport_do_not_modify_code()] do
    [
      defmodule NewPassport do
        def get_new_passport(now, birthday, form) do
          with {:ok, timestamp} <- enter_building(now),
               {:ok, manual} <- find_counter_information(now),
               counter <- manual.(birthday),
               {:ok, checksum} <- stamp_form(timestamp, counter, form) do
            {:ok, get_new_passport_number(timestamp, counter, checksum)}
          else
            {:coffee_break, _} ->
              {:retry, NaiveDateTime.add(now, 15 * 60, :second)}

            err ->
              err
          end
        end

        # Do not modify the functions below

        defp enter_building(%NaiveDateTime{} = datetime) do
          day = Date.day_of_week(datetime)
          time = NaiveDateTime.to_time(datetime)

          cond do
            day <= 4 and time_between(time, ~T[13:00:00], ~T[15:30:00]) ->
              {:ok, datetime |> DateTime.from_naive!("Etc/UTC") |> DateTime.to_unix()}

            # change == to >= here
            day >= 5 and time_between(time, ~T[13:00:00], ~T[14:30:00]) ->
              {:ok, datetime |> DateTime.from_naive!("Etc/UTC") |> DateTime.to_unix()}

            true ->
              {:error, "city office is closed"}
          end
        end

        @eighteen_years 18 * 365
        defp find_counter_information(%NaiveDateTime{} = datetime) do
          time = NaiveDateTime.to_time(datetime)

          if time_between(time, ~T[14:00:00], ~T[14:20:00]) do
            {:coffee_break, "information counter staff on coffee break, come back in 15 minutes"}
          else
            {:ok,
             fn %Date{} = birthday -> 1 + div(Date.diff(datetime, birthday), @eighteen_years) end}
          end
        end

        defp stamp_form(timestamp, counter, :blue) when rem(counter, 2) == 1 do
          {:ok, 3 * (timestamp + counter) + 1}
        end

        defp stamp_form(timestamp, counter, :red) when rem(counter, 2) == 0 do
          {:ok, div(timestamp + counter, 2)}
        end

        defp stamp_form(_timestamp, _counter, _form), do: {:error, "wrong form color"}

        defp get_new_passport_number(timestamp, counter, checksum) do
          "#{timestamp}-#{counter}-#{checksum}"
        end

        defp time_between(time, from, to) do
          Time.compare(from, time) != :gt and Time.compare(to, time) == :gt
        end
      end
    ]
  end
end
