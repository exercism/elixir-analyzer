defmodule ElixirAnalyzer.ExerciseTest.GottSnatchEmAllTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.GottaSnatchEmAll

  test_exercise_analysis "example solution",
    comments: [ElixirAnalyzer.Constants.solution_same_as_exemplar()] do
    defmodule GottaSnatchEmAll do
      @type card :: String.t()
      @type collection :: MapSet.t(card())

      @spec new_collection(card()) :: collection()
      def new_collection(card) do
        MapSet.new([card])
      end

      @spec add_card(card(), collection()) :: {boolean(), collection()}
      def add_card(card, collection) do
        {MapSet.member?(collection, card), MapSet.put(collection, card)}
      end

      @spec trade_card(card(), card(), collection()) :: {boolean(), collection()}
      def trade_card(your_card, their_card, collection) do
        can_trade? =
          MapSet.member?(collection, your_card) and not MapSet.member?(collection, their_card)

        updated_collection =
          collection
          |> MapSet.delete(your_card)
          |> MapSet.put(their_card)

        {can_trade?, updated_collection}
      end

      @spec remove_duplicates([card()]) :: [card()]
      def remove_duplicates(cards) do
        cards
        |> MapSet.new()
        |> MapSet.to_list()
        |> Enum.sort()
      end

      @spec extra_cards(collection(), collection()) :: non_neg_integer()
      def extra_cards(your_collection, their_collection) do
        your_collection
        |> MapSet.difference(their_collection)
        |> MapSet.size()
      end

      @spec boring_cards([collection()]) :: [card()]
      def boring_cards(collections) do
        case collections do
          [] ->
            []

          [collection | rest] ->
            Enum.reduce(rest, collection, &MapSet.intersection/2)
            |> MapSet.to_list()
            |> Enum.sort()
        end
      end

      @spec total_cards([collection()]) :: non_neg_integer()
      def total_cards(collections) do
        collections
        |> Enum.reduce(MapSet.new(), &MapSet.union/2)
        |> MapSet.size()
      end

      @spec split_shiny_cards(collection()) :: {[card()], [card()]}
      def split_shiny_cards(collection) do
        {shiny, not_shiny} = split_with(collection, &String.starts_with?(&1, "Shiny"))

        shiny_list = shiny |> MapSet.to_list() |> Enum.sort()
        not_shiny_list = not_shiny |> MapSet.to_list() |> Enum.sort()

        {shiny_list, not_shiny_list}
      end

      defp split_with(mapset, predicate) do
        init = {MapSet.new(), MapSet.new()}

        Enum.reduce(mapset, init, fn item, {passes, fails} ->
          if predicate.(item) do
            {MapSet.put(passes, item), fails}
          else
            {passes, MapSet.put(fails, item)}
          end
        end)
      end
    end
  end

  test_exercise_analysis "does not use use MapSet.member or MapSet.put in add_card",
    comments_include: [
      ElixirAnalyzer.Constants.gotta_snatch_em_all_add_card_use_mapset_member_and_put()
    ] do
    [
      defmodule GottaSnatchEmAll do
        def add_card(card, collection) when is_binary(card) and is_map(collection) do
          case MapSet.put(collection, card) do
            ^collection -> {true, collection}
            new_collection -> {false, new_collection}
          end
        end
      end,
      defmodule GottaSnatchEmAll do
        def add_card(card, collection) when is_binary(card) and is_map(collection) do
          {Enum.member?(collection, card), MapSet.put(collection, card)}
        end
      end,
      defmodule GottaSnatchEmAll do
        def add_card(card, collection) when is_binary(card) and is_map(collection) do
          {Enum.any?(collection, &(&1 === card)), MapSet.put(collection, card)}
        end
      end,
      defmodule GottaSnatchEmAll do
        def add_card(card, collection) when is_binary(card) and is_map(collection) do
          {MapSet.member?(collection, card), Enum.into([card], collection)}
        end
      end
    ]
  end

  test_exercise_analysis "does not use MapSet.member, MapSet.put or MapSet.delete in trade_card",
    comments_include: [
      ElixirAnalyzer.Constants.gotta_snatch_em_all_trade_card_use_mapset_member_put_and_delete()
    ] do
    [
      defmodule GottaSnatchEmAll do
        def trade_card(your_card, their_card, collection) do
          can_trade? =
            Enum.member?(collection, your_card) and not Enum.member?(collection, their_card)

          updated_collection =
            collection
            |> MapSet.delete(your_card)
            |> MapSet.put(their_card)

          {can_trade?, updated_collection}
        end
      end,
      defmodule GottaSnatchEmAll do
        def trade_card(your_card, their_card, collection) do
          can_trade? =
            MapSet.member?(collection, your_card) and not MapSet.member?(collection, their_card)

          updated_collection =
            collection
            |> MapSet.reject(&(&1 === your_card))
            |> MapSet.put(their_card)

          {can_trade?, updated_collection}
        end
      end,
      defmodule GottaSnatchEmAll do
        def trade_card(your_card, their_card, collection) do
          can_trade? =
            MapSet.member?(collection, your_card) and not MapSet.member?(collection, their_card)

          updated_collection =
            collection
            |> MapSet.delete(your_card)

          {can_trade?, Enum.into([their_card], updated_collection)}
        end
      end
    ]
  end

  test_exercise_analysis "does not use MapSet.new in remove_duplicates",
    comments_include: [
      ElixirAnalyzer.Constants.gotta_snatch_em_all_remove_duplicates_use_mapset_new()
    ] do
    [
      defmodule GottaSnatchEmAll do
        def remove_duplicates(cards) do
          cards
          |> Enum.into(%{}, &{&1, true})
          |> Map.keys()
          |> Enum.sort()
        end
      end
    ]
  end

  test_exercise_analysis "detect unsorted output from remove_duplicates",
    comments_include: [
      ElixirAnalyzer.Constants.gotta_snatch_em_all_remove_duplicates_use_enum_sort()
    ] do
    [
      defmodule GottaSnatchEmAll do
        def remove_duplicates(cards) do
          cards
          |> MapSet.new()
          |> MapSet.to_list()
        end
      end
    ]
  end

  test_exercise_analysis "detect Enum.uniq usage in remove_duplicates",
    comments_include: [
      ElixirAnalyzer.Constants.gotta_snatch_em_all_remove_duplicates_use_mapset_new(),
      ElixirAnalyzer.Constants.gotta_snatch_em_all_remove_duplicates_do_not_use_enum_uniq()
    ] do
    [
      defmodule GottaSnatchEmAll do
        def remove_duplicates(cards) do
          cards
          |> Enum.uniq()
          |> Enum.sort()
        end
      end
    ]
  end

  test_exercise_analysis "does not use MapSet.difference in extra_cards",
    comments_include: [
      ElixirAnalyzer.Constants.gotta_snatch_em_all_extra_cards_use_mapset_difference_and_size()
    ] do
    [
      defmodule GottaSnatchEmAll do
        def extra_cards(your_collection, their_collection) do
          your_collection
          |> MapSet.reject(fn card -> MapSet.member?(their_collection, card) end)
          |> MapSet.size()
        end
      end
    ]
  end

  test_exercise_analysis "does not use MapSet.size in extra_cards",
    comments_include: [
      ElixirAnalyzer.Constants.gotta_snatch_em_all_extra_cards_use_mapset_difference_and_size()
    ] do
    [
      defmodule GottaSnatchEmAll do
        def extra_cards(your_collection, their_collection) do
          MapSet.difference(your_collection, their_collection)
          |> Enum.count()
        end
      end,
      defmodule GottaSnatchEmAll do
        def extra_cards(your_collection, their_collection) do
          MapSet.difference(your_collection, their_collection)
          |> length
        end
      end
    ]
  end

  test_exercise_analysis "does not use MapSet.intersection in boring_cards",
    comments_include: [
      ElixirAnalyzer.Constants.gotta_snatch_em_all_boring_cards_use_mapset_intersection()
    ] do
    [
      defmodule GottaSnatchEmAll do
        def boring_cards([]), do: []
        def boring_cards([first]), do: MapSet.to_list(first) |> Enum.sort()

        def boring_cards(collections) do
          rest
          |> Enum.reduce(first, fn set1, set2 ->
            MapSet.filter(set1, fn item -> MapSet.member?(set2, item) end)
          end)
          |> Enum.sort()
        end
      end,
      defmodule GottaSnatchEmAll do
        def boring_cards([]), do: []
        def boring_cards([first]), do: MapSet.to_list(first) |> Enum.sort()

        def boring_cards(cards) do
          rest
          |> Enum.reduce(first, fn set1, set2 -> for item <- set1, item in set2, do: item end)
          |> Enum.sort()
        end
      end
    ]
  end

  test_exercise_analysis "detect unsorted output from boring_cards",
    comments_include: [
      ElixirAnalyzer.Constants.gotta_snatch_em_all_boring_cards_use_enum_sort()
    ] do
    [
      def boring_cards(collections) do
        case collections do
          [] ->
            []

          [collection | rest] ->
            Enum.reduce(rest, collection, &MapSet.intersection/2)
            |> MapSet.to_list()
        end
      end
    ]
  end

  test_exercise_analysis "does not use Enum.reduce in boring_cards",
    comments_include: [
      ElixirAnalyzer.Constants.gotta_snatch_em_all_boring_cards_use_enum_reduce()
    ] do
    [
      defmodule GottaSnatchEmAll do
        def boring_cards([]), do: []
        def boring_cards([first]), do: MapSet.to_list(first) |> Enum.sort()
        def boring_cards([first | rest]), do: do_boring_cards(rest, first)

        defp do_boring_cards([], acc), do: MapSet.to_list(acc) |> Enum.sort()

        defp do_boring_cards([next | rest], acc),
          do: do_boring_cards(rest, MapSet.intersection(acc, next))
      end
    ]
  end

  test_exercise_analysis "does not use MapSet.union in total_cards",
    comments_include: [
      ElixirAnalyzer.Constants.gotta_snatch_em_all_total_cards_use_mapset_union_and_size()
    ] do
    [
      defmodule GottaSnatchEmAll do
        def total_cards(collections) do
          collections
          |> Enum.reduce([], &Enum.concat/2)
          |> Enum.uniq()
          |> Enum.count()
        end
      end,
      defmodule GottaSnatchEmAll do
        def total_cards(collections) do
          collections
          |> Enum.reduce(MapSet.new([]), fn set, acc ->
            Enum.reduce(set, acc, fn i, acc2 -> MapSet.put(acc2, i) end)
          end)
          |> MapSet.size()
        end
      end
    ]
  end

  test_exercise_analysis "does not use MapSet.size in total_cards",
    comments_include: [
      ElixirAnalyzer.Constants.gotta_snatch_em_all_total_cards_use_mapset_union_and_size()
    ] do
    [
      defmodule GottaSnatchEmAll do
        def total_cards(collections) do
          collections
          |> Enum.reduce(MapSet.new(), &MapSet.union/2)
          |> Enum.count()
        end
      end,
      defmodule GottaSnatchEmAll do
        def total_cards(collections) do
          collections
          |> Enum.reduce(MapSet.new(), &MapSet.union/2)
          |> length
        end
      end
    ]
  end

  test_exercise_analysis "does not use String.starts_with? in split_shiny_cards",
    comments_include: [
      ElixirAnalyzer.Constants.gotta_snatch_em_all_split_shiny_cards_use_string_starts_with()
    ] do
    [
      defmodule GottaSnatchEmAll do
        def split_shiny_cards(collections) do
          {shiny, others} = MapSet.split_with(collection, &String.match?(&1, ~r/^Shiny/))
          {MapSet.to_list(shiny) |> Enum.sort(), MapSet.to_list(others) |> Enum.sort()}
        end
      end
    ]
  end

  test_exercise_analysis "detect unsorted output from split_shiny_cards",
    comments_include: [
      ElixirAnalyzer.Constants.gotta_snatch_em_all_split_shiny_cards_use_enum_sort()
    ] do
    [
      defmodule GottaSnatchEmAll do
        def split_shiny_cards(collections) do
          {shiny, others} = MapSet.split_with(collection, &String.starts_with?(&1, "Shiny"))
          {MapSet.to_list(shiny), MapSet.to_list(others)}
        end
      end
    ]
  end
end
