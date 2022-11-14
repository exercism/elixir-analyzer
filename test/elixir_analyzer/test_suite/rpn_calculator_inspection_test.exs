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
      end,
      defmodule RPNCalculatorInspection do
        def start_reliability_check(calculator, input) do
          pid = Kernel.spawn_link(fn -> calculator.(input) end)
          %{pid: pid, input: input}
        end

        def await_reliability_check_result(%{pid: pid, input: input}, results) do
          receive do
            {:EXIT, ^pid, :normal} -> results |> Map.put(input, :ok)
            {:EXIT, ^pid, _error} -> results |> Map.put(input, :error)
          after
            100 -> results |> Map.put(input, :timeout)
          end
        end

        def reliability_check(calculator, inputs) do
          {_trap_exit, init_trap_exit} = Process.info(self(), :trap_exit)
          Process.flag(:trap_exit, true)

          results =
            inputs
            |> Enum.map(fn input -> start_reliability_check(calculator, input) end)
            |> Enum.map(fn check -> await_reliability_check_result(check, %{}) end)
            |> Enum.flat_map(fn result -> result end)
            |> Enum.into(%{})

          Process.flag(:trap_exit, init_trap_exit)
          results
        end

        def correctness_check(calculator, inputs) do
          inputs
          |> Enum.map(fn input -> Task.async(fn -> calculator.(input) end) end)
          |> Enum.map(fn task -> Task.await(task, 100) end)
        end
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
