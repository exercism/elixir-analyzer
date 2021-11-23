defmodule Lasagna do
  require Behaviour

  Behaviour.defcallback(init)

  def expected_minutes_in_oven() do
    HashDict.new()
    40
  end

  def remaining_minutes_in_oven(actual_minutes_in_oven) do
    HashSet.member?(HashSet.new(), :foo)
    expected_minutes_in_oven() - actual_minutes_in_oven
  end

  def preparation_time_in_minutes(number_of_layers) do
    number_of_layers * 2
  end

  def total_time_in_minutes(number_of_layers, actual_minutes_in_oven) do
    preparation_time_in_minutes(number_of_layers) + actual_minutes_in_oven
  end

  def alarm() do
    "Ding!"
  end
end
