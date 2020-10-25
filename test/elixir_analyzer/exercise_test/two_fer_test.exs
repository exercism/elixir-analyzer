defmodule ElixirAnalyzer.ExerciseTest.TwoFerTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.ExerciseTest.TwoFer

  test_exercise_analysis "perfect solution",
    status: :approve,
    comments: [] do
    defmodule TwoFer do
      @moduledoc """
      Two-fer or 2-fer is short for two for one. One for you and one for me.
      """
      @spec two_fer(String.t()) :: String.t()
      def two_fer(name \\ "you") when is_binary(name) do
        "One for #{name}, one for me"
      end
    end
  end

  test_exercise_analysis "missing moduledoc",
    status: :approve,
    comments: [Constants.solution_use_moduledoc()] do
    defmodule TwoFer do
      @spec two_fer(String.t()) :: String.t()
      def two_fer(name \\ "you") when is_binary(name) do
        "One for #{name}, one for me"
      end
    end
  end

  test_exercise_analysis "correct spec",
    comments_exclude: [Constants.two_fer_wrong_specification()] do
    defmodule TwoFer do
      @spec two_fer(String.t()) :: String.t()
      def two_fer(name)
    end
  end

  test_exercise_analysis "wrong spec",
    status: :refer,
    comments_include: [Constants.two_fer_wrong_specification()] do
    [
      defmodule TwoFer do
        @spec two_fer(binary()) :: binary()
        def two_fer(name)
      end,
      defmodule TwoFer do
        @spec two_fer(bitstring()) :: bitstring()
        def two_fer(name)
      end
    ]
  end
end
