defmodule ElixirAnalyzer.ExerciseTest.FreelancerRatesTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.FreelancerRates

  test_exercise_analysis "example solution",
    comments: [] do
    [
      defmodule FreelancerRates do
        def daily_rate(hourly_rate) do
          hourly_rate * 8.0
        end

        def apply_discount(before_discount, discount) do
          before_discount - before_discount * (discount / 100.0)
        end

        def monthly_rate(hourly_rate, discount) do
          monthly_rate_before_discount = daily_rate(hourly_rate) * 22.0
          monthly_rate_after_discount = apply_discount(monthly_rate_before_discount, discount)
          trunc(Float.ceil(monthly_rate_after_discount))
        end

        def days_in_budget(budget, hourly_rate, discount) do
          daily_rate_before_discount = daily_rate(hourly_rate)
          daily_rate_after_discount = apply_discount(daily_rate_before_discount, discount)
          days_in_budget = budget / daily_rate_after_discount
          Float.floor(days_in_budget, 1)
        end
      end,
      defmodule FreelancerRates do
        def daily_rate(hourly_rate) do
          hourly_rate * 8.0
        end

        def apply_discount(before_discount, discount) do
          before_discount - before_discount * (discount / 100.0)
        end

        defp discounted_daily_rate(hourly_rate, discount) do
          hourly_rate
          |> apply_discount(discount)
          |> daily_rate()
        end

        def monthly_rate(hourly_rate, discount) do
          ceil(22 * discounted_daily_rate(hourly_rate, discount))
        end

        def days_in_budget(budget, hourly_rate, discount) do
          daily_rate = discounted_daily_rate(hourly_rate, discount)

          Float.floor(budget / daily_rate, 1)
        end
      end
    ]
  end

  describe "apply_discount/2 function reuse" do
    test_exercise_analysis "requires monthly_rate/2 to call apply_discount/2",
      comments: [Constants.freelancer_rates_apply_discount_function_reuse()] do
      defmodule FreelancerRates do
        def monthly_rate(hourly_rate, discount) do
          monthly_rate_before_discount = daily_rate(hourly_rate) * 22.0

          monthly_rate_after_discount =
            monthly_rate_before_discount - monthly_rate_before_discount * (discount / 100.0)

          trunc(Float.ceil(monthly_rate_after_discount))
        end
      end
    end

    test_exercise_analysis "requires days_in_budget/3 to call apply_discount/2",
      comments: [Constants.freelancer_rates_apply_discount_function_reuse()] do
      defmodule FreelancerRates do
        def days_in_budget(budget, hourly_rate, discount) do
          daily_rate_before_discount = daily_rate(hourly_rate)

          daily_rate_after_discount =
            daily_rate_before_discount - daily_rate_before_discount * (discount / 100.0)

          days_in_budget = budget / daily_rate_after_discount
          Float.floor(days_in_budget, 1)
        end
      end
    end

    test_exercise_analysis "comment appears only once if both functions don't use apply_discount/2",
      comments: [Constants.freelancer_rates_apply_discount_function_reuse()] do
      defmodule FreelancerRates do
        def monthly_rate(hourly_rate, discount) do
          monthly_rate_before_discount = daily_rate(hourly_rate) * 22.0

          monthly_rate_after_discount =
            monthly_rate_before_discount - monthly_rate_before_discount * (discount / 100.0)

          trunc(Float.ceil(monthly_rate_after_discount))
        end

        def days_in_budget(budget, hourly_rate, discount) do
          daily_rate_before_discount = daily_rate(hourly_rate)

          daily_rate_after_discount =
            daily_rate_before_discount - daily_rate_before_discount * (discount / 100.0)

          days_in_budget = budget / daily_rate_after_discount
          Float.floor(days_in_budget, 1)
        end
      end
    end

    test_exercise_analysis "calling function should match",
      comments: [Constants.freelancer_rates_apply_discount_function_reuse()] do
      defmodule FreelancerRates do
        def daily_rate(hourly_rate) do
          hourly_rate * 8.0
        end

        def apply_discount(before_discount, discount) do
          before_discount - before_discount * (discount / 100.0)
        end

        def some_other_function() do
          apply_discount(100, 3)
        end
      end
    end
  end
end
