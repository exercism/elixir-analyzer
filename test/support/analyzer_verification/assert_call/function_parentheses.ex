defmodule ElixirAnalyzer.Support.AnalyzerVerification.AssertCall.FunctionParentheses do
  @moduledoc """
  This is an exercise analyzer extension module to test that feature accepts function calls of
  arity 0 with or without parentheses
  """

  use ElixirAnalyzer.ExerciseTest

  feature "run/0 defined with run()" do
    type :essential
    comment "did not match def run()"

    form do
      def run() do
        _ignore
      end
    end
  end

  feature "run/0 defined with run" do
    type :essential
    comment "did not match def run"

    form do
      def run do
        _ignore
      end
    end
  end

  feature "run/0 used with run()" do
    type :essential
    comment "did not match run()"

    form do
      _ignore = run()
    end
  end

  feature "run/0 used with run" do
    type :essential
    comment "did not match run"

    form do
      _ignore = run
    end
  end

  feature "run/0 used with run() in a pipe" do
    type :essential
    comment "did not match run() in a pipe"

    form do
      _ignore |> run()
    end
  end

  feature "run/0 used with run in a pipe" do
    type :essential
    comment "did not match run in a pipe"

    form do
      _ignore |> run
    end
  end
end
