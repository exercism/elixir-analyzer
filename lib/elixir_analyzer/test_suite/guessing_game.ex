defmodule ElixirAnalyzer.TestSuite.GuessingGame do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Guessing Game
  """

  use ElixirAnalyzer.ExerciseTest
  alias ElixirAnalyzer.Constants

  feature "uses guards" do
    find :any
    type :essential
    comment Constants.guessing_game_use_guards()

    form do
      def compare(_ignore, _ignore) when _ignore do
        _ignore
      end
    end
  end

  feature "uses default arguments" do
    find :any
    type :essential
    comment Constants.guessing_game_use_default_argument()

    form do
      def compare(_ignore, _ignore \\ :no_guess)
    end

    form do
      def compare(_ignore, _ignore \\ :no_guess) do
        _ignore
      end
    end

    form do
      def compare(_ignore, _ignore \\ :no_guess) when _ignore do
        _ignore
      end
    end
  end

  assert_no_call "doesn't use if, only multiple clause functions" do
    type :essential
    called_fn name: :if
    comment Constants.guessing_game_use_multiple_clause_functions()
  end

  assert_no_call "doesn't use case, only multiple clause functions" do
    type :essential
    called_fn name: :case
    comment Constants.guessing_game_use_multiple_clause_functions()
  end

  assert_no_call "doesn't use cond, only multiple clause functions" do
    type :essential
    called_fn name: :cond
    comment Constants.guessing_game_use_multiple_clause_functions()
  end
end
