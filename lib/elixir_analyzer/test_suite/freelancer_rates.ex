defmodule ElixirAnalyzer.TestSuite.FreelancerRates do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Freelancer Rates
  """

  use ElixirAnalyzer.ExerciseTest

  assert_call "monthly_rate/2 reuses apply_discount/2" do
    type :actionable
    calling_fn module: FreelancerRates, name: :monthly_rate
    called_fn name: :apply_discount
    comment ElixirAnalyzer.Constants.freelancer_rates_apply_discount_function_reuse()
  end

  assert_call "days_in_budget/2 reuses apply_discount/2" do
    type :actionable
    calling_fn module: FreelancerRates, name: :days_in_budget
    called_fn name: :apply_discount
    comment ElixirAnalyzer.Constants.freelancer_rates_apply_discount_function_reuse()
  end
end
