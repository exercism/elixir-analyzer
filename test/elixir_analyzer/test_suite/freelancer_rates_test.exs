defmodule ElixirAnalyzer.ExerciseTest.FreelancerRatesTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.FreelancerRates

  test_exercise_analysis "example solution",
    comments: [] do
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
    end
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
  end
end
