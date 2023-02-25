defmodule ElixirAnalyzer.Support.AnalyzerVerification.NoRescue do
  use ElixirAnalyzer.ExerciseTest
end

defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.NoRescueTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.Support.AnalyzerVerification.NoRescue

  alias ElixirAnalyzer.Constants

  test_exercise_analysis "Solutions without rescue",
    comments: [] do
    [
      defmodule MyModule do
        def get_first_day_of_month_in_99(month) do
          result = Date.new(1999, month, 1)

          case result do
            {:ok, date} -> date
            {:error, _error} -> nil
          end
        end
      end
    ]
  end

  test_exercise_analysis "Solutions with rescuing",
    comments_include: [Constants.solution_no_rescue()] do
    [
      # try/rescue
      defmodule MyModule do
        def get_first_day_of_month_in_99(month) do
          try do
            Date.new!(1999, month, 1)
          rescue
            _ ->
              nil
          end
        end
      end,
      # try/rescue multiline blocks
      defmodule MyModule do
        def get_first_day_of_month_in_99(month) do
          try do
            IO.inspect(month)
            Date.new!(1999, month, 1)
          rescue
            error ->
              IO.inspect(error)
              nil
          end
        end
      end,
      # try/rescue multi clause
      defmodule MyModule do
        def get_first_day_of_month_in_99(month) do
          try do
            IO.inspect(month)
            Date.new!(1999, month, 1)
          rescue
            error in [RuntimeError] ->
              IO.inspect(error)
              nil

            error in [ArgumentError] ->
              IO.inspect(error)
              nil
          end
        end
      end,
      # try/rescue/else multiline blocks
      defmodule MyModule do
        def get_first_day_of_month_in_99(month) do
          try do
            IO.inspect(month)
            Date.new!(1999, month, 1)
          rescue
            error ->
              IO.inspect(error)
              nil
          else
            the_value ->
              IO.inspect("my code is so bad, what am I doing with my life?")
              the_value
          end
        end
      end,
      # try/rescue/after multiline blocks
      defmodule MyModule do
        def get_first_day_of_month_in_99(month) do
          try do
            IO.inspect(month)
            Date.new!(1999, month, 1)
          rescue
            error ->
              IO.inspect(error)
              nil
          after
            IO.inspect("stop")
            IO.inspect("please")
          end
        end
      end,
      # try/rescue/else/after multiline blocks
      defmodule MyModule do
        def get_first_day_of_month_in_99(month) do
          try do
            IO.inspect(month)
            Date.new!(1999, month, 1)
          rescue
            error ->
              IO.inspect(error)
              nil
          else
            the_value ->
              IO.inspect("my code is so bad, what am I doing with my life?")
              the_value
          after
            IO.inspect("stop")
            IO.inspect("please")
          end
        end
      end,
      # try/rescue/after/else multiline blocks
      defmodule MyModule do
        def get_first_day_of_month_in_99(month) do
          try do
            IO.inspect(month)
            Date.new!(1999, month, 1)
          rescue
            error ->
              IO.inspect(error)
              nil
          after
            IO.inspect("stop")
            IO.inspect("please")
          else
            the_value ->
              IO.inspect("my code is so bad, what am I doing with my life?")
              the_value
          end
        end
      end,
      # try/rescue/after/else multi clause else multiline blocks
      defmodule MyModule do
        def get_first_day_of_month_in_99(month) do
          try do
            IO.inspect(month)
            Date.new!(1999, month, 1)
          rescue
            error ->
              IO.inspect(error)
              nil
          after
            IO.inspect("stop")
            IO.inspect("please")
          else
            :foo ->
              :bar

            the_value ->
              IO.inspect("my code is so bad, what am I doing with my life?")
              the_value
          end
        end
      end,
      # def/rescue
      defmodule MyModule do
        def get_first_day_of_month_in_99(month) do
          Date.new!(1999, month, 1)
        rescue
          _ ->
            nil
        end
      end,
      # def/rescue multiline blocks
      defmodule MyModule do
        def get_first_day_of_month_in_99(month) do
          IO.inspect(month)
          Date.new!(1999, month, 1)
        rescue
          error ->
            IO.inspect(error)
            nil
        end
      end,
      # def/rescue/else multiline blocks
      defmodule MyModule do
        def get_first_day_of_month_in_99(month) do
          IO.inspect(month)
          Date.new!(1999, month, 1)
        rescue
          error in [ArgumentError] ->
            IO.inspect(error)
            nil
        else
          the_value ->
            IO.inspect("my code is so bad, what am I doing with my life?")
            the_value
        end
      end,
      # def/rescue/after multiline blocks
      defmodule MyModule do
        def get_first_day_of_month_in_99(month) do
          IO.inspect(month)
          Date.new!(1999, month, 1)
        rescue
          error in [ArgumentError] ->
            IO.inspect(error)
            nil
        after
          IO.inspect("stop")
          IO.inspect("please")
        end
      end,
      # def/rescue/else/after multiline blocks
      defmodule MyModule do
        def get_first_day_of_month_in_99(month) do
          IO.inspect(month)
          Date.new!(1999, month, 1)
        rescue
          error in [ArgumentError] ->
            IO.inspect(error)
            nil
        else
          the_value ->
            IO.inspect("my code is so bad, what am I doing with my life?")
            the_value
        after
          IO.inspect("stop")
          IO.inspect("please")
        end
      end,
      # def/rescue/after/else multiline blocks
      defmodule MyModule do
        def get_first_day_of_month_in_99(month) do
          IO.inspect(month)
          Date.new!(1999, month, 1)
        rescue
          error in [ArgumentError] ->
            IO.inspect(error)
            nil
        after
          IO.inspect("stop")
          IO.inspect("please")
        else
          the_value ->
            IO.inspect("my code is so bad, what am I doing with my life?")
            the_value
        end
      end,

      # defp/rescue multiline blocks
      defmodule MyModule do
        defp get_first_day_of_month_in_99(month) do
          IO.inspect(month)
          Date.new!(1999, month, 1)
        rescue
          error ->
            IO.inspect(error)
            nil
        end
      end,
      # defp/rescue/else multiline blocks
      defmodule MyModule do
        defp get_first_day_of_month_in_99(month) do
          IO.inspect(month)
          Date.new!(1999, month, 1)
        rescue
          error in [ArgumentError] ->
            IO.inspect(error)
            nil
        else
          the_value ->
            IO.inspect("my code is so bad, what am I doing with my life?")
            the_value
        end
      end,
      # defp/rescue/after multiline blocks
      defmodule MyModule do
        defp get_first_day_of_month_in_99(month) do
          IO.inspect(month)
          Date.new!(1999, month, 1)
        rescue
          error in [ArgumentError] ->
            IO.inspect(error)
            nil
        after
          IO.inspect("stop")
          IO.inspect("please")
        end
      end,
      # defp/rescue/else/after multiline blocks
      defmodule MyModule do
        defp get_first_day_of_month_in_99(month) do
          IO.inspect(month)
          Date.new!(1999, month, 1)
        rescue
          error in [ArgumentError] ->
            IO.inspect(error)
            nil
        else
          the_value ->
            IO.inspect("my code is so bad, what am I doing with my life?")
            the_value
        after
          IO.inspect("stop")
          IO.inspect("please")
        end
      end,
      # defp/rescue/after/else multiline blocks
      defmodule MyModule do
        defp get_first_day_of_month_in_99(month) do
          IO.inspect(month)
          Date.new!(1999, month, 1)
        rescue
          error in [ArgumentError] ->
            IO.inspect(error)
            nil
        after
          IO.inspect("stop")
          IO.inspect("please")
        else
          the_value ->
            IO.inspect("my code is so bad, what am I doing with my life?")
            the_value
        end
      end
    ]
  end
end
