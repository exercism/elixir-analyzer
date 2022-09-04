defmodule ElixirAnalyzer.TestSuite.NewPassport do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise New Passport
  """

  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Source
  use ElixirAnalyzer.ExerciseTest

  assert_call "with is used in get_new_passport/3" do
    type :essential
    comment Constants.new_passport_use_with()
    calling_fn module: NewPassport, name: :get_new_passport
    called_fn name: :with
  end

  check_source "with is used with else in get_new_passport/3" do
    type :essential
    comment Constants.new_passport_use_with_else()
    suppress_if "with is used in get_new_passport/3", :fail

    check(%Source{code_ast: code_ast}) do
      {_, %{with_else_found?: found?}} =
        Macro.prewalk(
          code_ast,
          %{with_else_found?: false},
          &find_with_else_in_get_new_passport/2
        )

      found?
    end
  end

  feature "given code wasn't modified" do
    type :informative
    comment Constants.new_passport_do_not_modify_code()

    form do
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

  defp find_with_else_in_get_new_passport(
         {:def, _meta, [{:get_new_passport, _meta2, args}, [do: body]]} = node,
         %{with_else_found?: false} = acc
       )
       when length(args) == 3 do
    {_, with_else_found?} =
      Macro.prewalk(body, false, fn node, acc ->
        if acc do
          # stop looking if already found
          {node, acc}
        else
          acc =
            case node do
              # with clauses is a list of `{:->, _, _}` tuples ending with a do or do/else keyword list.
              {:with, _, clauses} ->
                case List.last(clauses) do
                  [do: _, else: _] -> true
                  _ -> false
                end

              _ ->
                false
            end

          {node, acc}
        end
      end)

    {node, Map.put(acc, :with_else_found?, with_else_found?)}
  end

  defp find_with_else_in_get_new_passport(node, acc) do
    {node, acc}
  end
end
