defmodule ElixirAnalyzer.TestSuite.BoutiqueInventory do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Boutique Inventory
  """

  use ElixirAnalyzer.ExerciseTest
  alias ElixirAnalyzer.Constants

  assert_call "sort_by_price uses Enum.sort_by" do
    type :essential
    calling_fn module: BoutiqueInventory, name: :sort_by_price
    called_fn module: Enum, name: :sort_by
    comment Constants.boutique_inventory_use_enum_sort_by()
  end

  assert_call "with_missing_price uses Enum.filter" do
    type :essential
    calling_fn module: BoutiqueInventory, name: :with_missing_price
    called_fn module: Enum, name: :filter
    comment Constants.boutique_inventory_use_enum_filter_or_enum_reject()
    suppress_if "with_missing_price uses Enum.reject", :pass
  end

  assert_call "with_missing_price uses Enum.reject" do
    type :essential
    calling_fn module: BoutiqueInventory, name: :with_missing_price
    called_fn module: Enum, name: :reject
    comment Constants.boutique_inventory_use_enum_filter_or_enum_reject()
    suppress_if "with_missing_price uses Enum.filter", :pass
  end

  assert_call "increase_quantity uses Enum.map" do
    type :essential
    calling_fn module: BoutiqueInventory, name: :increase_quantity
    called_fn module: Enum, name: :map
    comment Constants.boutique_inventory_use_enum_map()
  end

  assert_call "total_quantity uses Enum.reduce" do
    type :essential
    calling_fn module: BoutiqueInventory, name: :total_quantity
    called_fn module: Enum, name: :reduce
    comment Constants.boutique_inventory_use_enum_reduce()
  end
end
