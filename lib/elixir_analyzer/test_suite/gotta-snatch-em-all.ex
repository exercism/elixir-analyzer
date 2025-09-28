defmodule ElixirAnalyzer.TestSuite.GottaSnatchEmAll do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Gotta Snatch Em All
  """
  use ElixirAnalyzer.ExerciseTest
  alias ElixirAnalyzer.Constants

  assert_call "add_card uses MapSet.member?" do
    type :essential
    calling_fn module: GottaSnatchEmAll, name: :add_card
    called_fn module: MapSet, name: :member?
    comment Constants.gotta_snatch_em_all_add_card_use_mapset_member_and_put()
  end

  assert_call "add_card uses MapSet.put" do
    type :essential
    calling_fn module: GottaSnatchEmAll, name: :add_card
    called_fn module: MapSet, name: :put
    comment Constants.gotta_snatch_em_all_add_card_use_mapset_member_and_put()
    suppress_if "add_card uses MapSet.member?", :fail
  end

  assert_call "trade_card uses MapSet.member?" do
    type :essential
    calling_fn module: GottaSnatchEmAll, name: :trade_card
    called_fn module: MapSet, name: :member?
    comment Constants.gotta_snatch_em_all_trade_card_use_mapset_member_put_and_delete()
  end

  assert_call "trade_card uses MapSet.put" do
    type :essential
    calling_fn module: GottaSnatchEmAll, name: :trade_card
    called_fn module: MapSet, name: :put
    comment Constants.gotta_snatch_em_all_trade_card_use_mapset_member_put_and_delete()
    suppress_if "trade_card uses MapSet.member?", :fail
  end

  assert_call "trade_card uses MapSet.delete" do
    type :essential
    calling_fn module: GottaSnatchEmAll, name: :trade_card
    called_fn module: MapSet, name: :delete
    comment Constants.gotta_snatch_em_all_trade_card_use_mapset_member_put_and_delete()
    suppress_if "trade_card uses MapSet.member?", :fail
    suppress_if "trade_card uses MapSet.put", :fail
  end

  assert_call "remove_duplicates uses MapSet.new" do
    type :essential
    calling_fn module: GottaSnatchEmAll, name: :remove_duplicates
    called_fn module: MapSet, name: :new
    comment Constants.gotta_snatch_em_all_remove_duplicates_use_mapset_new()
  end

  assert_call "remove_duplicates uses Enum.sort" do
    type :essential
    calling_fn module: GottaSnatchEmAll, name: :remove_duplicates
    called_fn module: Enum, name: :sort
    comment Constants.gotta_snatch_em_all_remove_duplicates_use_enum_sort()
  end

  assert_no_call "remove_duplicates does not use Enum.uniq" do
    type :essential
    calling_fn module: GottaSnatchEmAll, name: :remove_duplicates
    called_fn module: Enum, name: :uniq
    comment Constants.gotta_snatch_em_all_remove_duplicates_do_not_use_enum_uniq()
  end

  assert_call "extra_cards uses MapSet.difference" do
    type :essential
    calling_fn module: GottaSnatchEmAll, name: :extra_cards
    called_fn module: MapSet, name: :difference
    comment Constants.gotta_snatch_em_all_extra_cards_use_mapset_difference_and_size()
  end

  assert_call "extra_cards uses MapSet.size" do
    type :essential
    calling_fn module: GottaSnatchEmAll, name: :extra_cards
    called_fn module: MapSet, name: :size
    comment Constants.gotta_snatch_em_all_extra_cards_use_mapset_difference_and_size()
    suppress_if "extra_cards uses MapSet.difference", :fail
  end

  assert_call "boring_cards uses MapSet.intersection" do
    type :essential
    calling_fn module: GottaSnatchEmAll, name: :boring_cards
    called_fn module: MapSet, name: :intersection
    comment Constants.gotta_snatch_em_all_boring_cards_use_mapset_intersection()
  end

  assert_call "boring_cards uses Enum.sort" do
    type :essential
    calling_fn module: GottaSnatchEmAll, name: :boring_cards
    called_fn module: Enum, name: :sort
    comment Constants.gotta_snatch_em_all_boring_cards_use_enum_sort()
  end

  assert_call "boring_cards uses Enum.reduce" do
    type :actionable
    calling_fn module: GottaSnatchEmAll, name: :boring_cards
    called_fn module: Enum, name: :reduce
    comment Constants.gotta_snatch_em_all_boring_cards_use_enum_reduce()
  end

  assert_call "total_cards uses MapSet.union" do
    type :essential
    calling_fn module: GottaSnatchEmAll, name: :total_cards
    called_fn module: MapSet, name: :union
    comment Constants.gotta_snatch_em_all_total_cards_use_mapset_union_and_size()
  end

  assert_call "total_cards uses MapSet.size" do
    type :essential
    calling_fn module: GottaSnatchEmAll, name: :total_cards
    called_fn module: MapSet, name: :size
    comment Constants.gotta_snatch_em_all_total_cards_use_mapset_union_and_size()
    suppress_if "total_cards uses MapSet.union", :fail
  end

  assert_call "total_cards uses Enum.reduce" do
    type :actionable
    calling_fn module: GottaSnatchEmAll, name: :total_cards
    called_fn module: Enum, name: :reduce
    comment Constants.gotta_snatch_em_all_total_cards_use_enum_reduce()
  end

  assert_call "split_shiny_cards uses Enum.sort" do
    type :essential
    calling_fn module: GottaSnatchEmAll, name: :split_shiny_cards
    called_fn module: Enum, name: :sort
    comment Constants.gotta_snatch_em_all_split_shiny_cards_use_enum_sort()
  end

  assert_call "split_shiny_cards uses String.starts_with" do
    type :actionable
    calling_fn module: GottaSnatchEmAll, name: :split_shiny_cards
    called_fn module: String, name: :starts_with?
    comment Constants.gotta_snatch_em_all_split_shiny_cards_use_string_starts_with()
  end
end
