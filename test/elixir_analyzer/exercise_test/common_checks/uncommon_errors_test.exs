defmodule ElixirAnalyzer.Support.AnalyzerVerification.UncommonErrors do
  use ElixirAnalyzer.ExerciseTest
end

defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.UncommonErrorsTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.Support.AnalyzerVerification.UncommonErrors

  alias ElixirAnalyzer.Constants

  describe "FunctionClauseError" do
    test_exercise_analysis "solutions which do not raise FunctionClauseError",
      comments: [] do
      [
        defmodule MyModule do
          def f(n), do: :ok
        end,
        defmodule MyModule do
          def f(1), do: :ok
          def g(), do: f(2)
        end
      ]
    end

    test_exercise_analysis "solutions which raise FunctionClauseError",
      comments: [Constants.solution_raise_fn_clause_error()] do
      [
        defmodule MyModule do
          def f(1), do: :ok
          def f(_), do: raise(FunctionClauseError)
        end,
        defmodule MyModule do
          def f(1), do: :ok
          def f(_), do: raise(%FunctionClauseError{})
        end
      ]
    end
  end
end
