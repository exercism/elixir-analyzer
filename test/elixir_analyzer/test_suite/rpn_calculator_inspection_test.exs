defmodule ElixirAnalyzer.ExerciseTest.RpnCalculatorInspectionTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.RpnCalculatorInspection

  test_exercise_analysis "example solutions",
    comments: [] do
    [
      defmodule RpnCalculatorInspection do
        def start_reliability_check(calculator, input) do
          %{input: input, pid: spawn_link(fn -> calculator.(input) end)}
        end

        # More functions...
      end,
      defmodule RpnCalculatorInspection do
        def start_reliability_check(calculator, input) do
          %{input: input, pid: Task.start_link(fn -> calculator.(input) end)}
        end

        # More functions...
      end
    ]
  end

  test_exercise_analysis "calls Process.link",
    comments: [Constants.rpn_calculator_inspection_use_start_link()] do
    defmodule RpnCalculatorInspection do
      def start_reliability_check(calculator, input) do
        pid = spawn(fn -> calculator.(input) end)
        Process.link(pid)
        %{input: input, pid: pid}
      end
    end
  end
end
