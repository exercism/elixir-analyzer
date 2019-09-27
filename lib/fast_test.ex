defmodule FastTest do
  def run_a() do
    ElixirAnalyzer.analyze_exercise("two-fer", "./test_data/two_fer/passing_solution/")
  end

  def run_b() do
    ElixirAnalyzer.analyze_exercise("two-fer", "./test_data/two_fer/failing_solution/")
  end
end
