defmodule ElixirAnalyzer.ExerciseTest.BoutiqueInventoryTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.BoutiqueInventory

  test_exercise_analysis "example solution",
    comments: [ElixirAnalyzer.Constants.solution_same_as_exemplar()] do
    defmodule BoutiqueInventory do
      def sort_by_price(inventory) do
        Enum.sort_by(inventory, fn item -> Map.get(item, :price) end)
      end

      def with_missing_price(inventory) do
        Enum.filter(inventory, fn item -> Map.get(item, :price) == nil end)
      end

      def update_names(inventory, old_word, new_word) do
        Enum.map(inventory, fn item ->
          Map.update!(item, :name, fn name -> String.replace(name, old_word, new_word) end)
        end)
      end

      def increase_quantity(item, count) do
        Map.update(item, :quantity_by_size, %{}, fn quantity_by_size ->
          quantity_by_size
          |> Map.new(fn {size, quantity} -> {size, quantity + count} end)
        end)
      end

      def total_quantity(item) do
        Enum.reduce(Map.get(item, :quantity_by_size), 0, fn {_size, quantity}, acc ->
          acc + quantity
        end)
      end
    end
  end

  test_exercise_analysis "correct solution using Enum.reject instead Enum.filter",
    comments_exclude: [
      ElixirAnalyzer.Constants.boutique_inventory_use_enum_filter_or_enum_reject()
    ] do
    defmodule BoutiqueInventory do
      def with_missing_price(inventory) do
        Enum.reject(inventory, fn item -> Map.get(item, :price) != nil end)
      end
    end
  end

  describe "fail solutions" do
    test_exercise_analysis "sort_by_price not using Enum.sort_by",
      comments_include: [ElixirAnalyzer.Constants.boutique_inventory_use_enum_sort_by()] do
      defmodule BoutiqueInventory do
        def sort_by_price(inventory) do
          Enum.sort(inventory, &(&1.price <= &2.price))
        end
      end
    end

    test_exercise_analysis "with_missing_price not using Enum.filter or Enum.reject",
      comments_include: [
        ElixirAnalyzer.Constants.boutique_inventory_use_enum_filter_or_enum_reject()
      ] do
      defmodule BoutiqueInventory do
        def with_missing_price(inventory) do
          Enum.reduce(inventory, [], fn item, acc ->
            if is_nil(item.price), do: List.insert_at(acc, -1, item), else: acc
          end)
        end
      end
    end

    test_exercise_analysis "increase_quantity should use either Enum.into or Map.new",
      comments_exclude: [
        ElixirAnalyzer.Constants.boutique_inventory_increase_quantity_best_function_choice()
      ] do
      [
        defmodule BoutiqueInventory do
          def increase_quantity(item, count) do
            Map.update(item, :quantity_by_size, %{}, fn quantity_by_size ->
              quantity_by_size
              |> Enum.into(%{}, fn {size, quantity} -> {size, quantity + count} end)
            end)
          end
        end,
        defmodule BoutiqueInventory do
          def increase_quantity(item, count) do
            Map.update(item, :quantity_by_size, %{}, fn quantity_by_size ->
              quantity_by_size
              |> Map.new(fn {size, quantity} -> {size, quantity + count} end)
            end)
          end
        end
      ]
    end

    test_exercise_analysis "increase_quantity should use just Enum.into instead of Enum.map + Enum.into or something else",
      comments_include: [
        ElixirAnalyzer.Constants.boutique_inventory_increase_quantity_best_function_choice()
      ] do
      [
        defmodule BoutiqueInventory do
          def increase_quantity(item, count) do
            Map.update(item, :quantity_by_size, %{}, fn quantity_by_size ->
              quantity_by_size
              |> Enum.map(fn {size, quantity} -> {size, quantity + count} end)
              |> Enum.into(%{})
            end)
          end
        end,
        def increase_quantity(item, count) do
          Map.update(item, :quantity_by_size, %{}, fn quantity_by_size ->
            quantity_by_size
            |> Map.keys()
            |> Enum.reduce(item.quantity_by_size, fn size, acc ->
              Map.update!(acc, size, &(&1 + count))
            end)
          end)
        end,
        def increase_quantity(item, count) do
          item.quantity_by_size
          |> Map.keys()
          |> Enum.map(&[:quantity_by_size, &1])
          |> Enum.reduce(item, fn keys, acc ->
            update_in(acc, keys, &(&1 + count))
          end)
        end
      ]
    end

    test_exercise_analysis "total_quantity not using Enum.reduce",
      comments_include: [ElixirAnalyzer.Constants.boutique_inventory_use_enum_reduce()] do
      defmodule BoutiqueInventory do
        def total_quantity(item) do
          item[:quantity_by_size]
          |> Map.values()
          |> Enum.sum()
        end
      end
    end
  end
end
