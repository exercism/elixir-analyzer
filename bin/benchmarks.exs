Logger.configure(level: :error)

options = [puts_summary: false, write_results: false]
perfect_path = "./test_data/two_fer/perfect_solution/"
imperfect_path = "./test_data/two_fer/imperfect_solution/"

Benchee.run(
  %{
    "perfect two-fer" => fn ->
      ElixirAnalyzer.analyze_exercise("two-fer", perfect_path, perfect_path, options)
    end,
    "imperfect two-fer" => fn ->
      ElixirAnalyzer.analyze_exercise("two-fer", imperfect_path, imperfect_path, options)
    end
  },
  time: 10,
  memory_time: 2
)
