defmodule ElixirAnalyzer.ExerciseTest.LogLevelTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.LogLevel

  test_exercise_analysis "example solution",
    comments: [Constants.solution_same_as_exemplar()] do
    [
      defmodule LogLevel do
        def to_label(level, legacy?) do
          cond do
            level === 0 && not legacy? -> :trace
            level === 1 -> :debug
            level === 2 -> :info
            level === 3 -> :warning
            level === 4 -> :error
            level === 5 && not legacy? -> :fatal
            true -> :unknown
          end
        end

        def alert_recipient(level, legacy?) do
          label = to_label(level, legacy?)

          cond do
            label == :fatal -> :ops
            label == :error -> :ops
            label == :unknown && legacy? -> :dev1
            label == :unknown -> :dev2
            true -> false
          end
        end
      end
    ]
  end

  test_exercise_analysis "requires usage of cond/1",
    comments: [Constants.log_level_use_cond()] do
    [
      defmodule LogLevel do
        def to_label(0, false), do: :trace
        def to_label(1, _), do: :debug
        def to_label(2, _), do: :info
        def to_label(3, _), do: :warning
        def to_label(4, _), do: :error
        def to_label(5, false), do: :fatal
        def to_label(_, _), do: :unknown

        def alert_recipient(:fatal, _), do: :ops
        def alert_recipient(:error, _), do: :ops
        def alert_recipient(:unknown, true), do: :dev1
        def alert_recipient(:unknown, _), do: :dev2
        def alert_recipient(_, _), do: false
      end
    ]
  end
end
