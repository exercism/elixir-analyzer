defmodule ElixirAnalyzer.TestSuite.Chessboard do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Chessboard
  """

  use ElixirAnalyzer.ExerciseTest

  assert_call "ranks calls rank_range" do
    type :actionable
    comment ElixirAnalyzer.Constants.chessboard_function_reuse()
    called_fn name: :rank_range
    calling_fn module: Chessboard, name: :ranks
  end

  assert_call "files calls file_range" do
    type :actionable
    comment ElixirAnalyzer.Constants.chessboard_function_reuse()
    called_fn name: :file_range
    calling_fn module: Chessboard, name: :files
  end

  feature "change codepoint to string directly" do
    type :actionable
    comment ElixirAnalyzer.Constants.chessboard_change_codepoint_to_string_directly()

    form do
      <<_ignore>>
    end
  end
end
