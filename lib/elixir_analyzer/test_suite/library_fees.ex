defmodule ElixirAnalyzer.TestSuite.LibraryFees do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Library Fees
  """

  use ElixirAnalyzer.ExerciseTest
  alias ElixirAnalyzer.Constants

  assert_call "calculate_late_fee/3 uses datetime_from_string/1" do
    type :essential
    calling_fn module: LibraryFees, name: :calculate_late_fee
    called_fn module: LibraryFees, name: :datetime_from_string
    comment Constants.library_fees_function_reuse()
  end

  assert_call "calculate_late_fee/3 uses return_date/1" do
    type :essential
    calling_fn module: LibraryFees, name: :calculate_late_fee
    called_fn module: LibraryFees, name: :return_date
    comment Constants.library_fees_function_reuse()
  end

  assert_call "calculate_late_fee/3 uses days_late/2" do
    type :essential
    calling_fn module: LibraryFees, name: :calculate_late_fee
    called_fn module: LibraryFees, name: :days_late
    comment Constants.library_fees_function_reuse()
  end

  assert_call "calculate_late_fee/3 uses monday?/1" do
    type :essential
    calling_fn module: LibraryFees, name: :calculate_late_fee
    called_fn module: LibraryFees, name: :monday?
    comment Constants.library_fees_function_reuse()
  end
end
