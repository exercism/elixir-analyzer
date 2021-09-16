defmodule ElixirAnalyzer.ExerciseTest.BoutiqueSuggestionsTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.BoutiqueSuggestions

  test_exercise_analysis "example solution",
    comments: [ElixirAnalyzer.Constants.solution_same_as_exemplar()] do
    [
      defmodule BoutiqueSuggestions do
        def get_combinations(tops, bottoms, options \\ []) do
          maximum_price = Keyword.get(options, :maximum_price, 100.00)

          for top <- tops,
              %{base_color: top_base_color, price: top_price} = top,
              bottom <- bottoms,
              %{base_color: bottom_base_color, price: bottom_price} = bottom,
              top_base_color != bottom_base_color,
              top_price + bottom_price <= maximum_price do
            {top, bottom}
          end
        end
      end
    ]
  end

  test_exercise_analysis "correct solutions",
    comments: [] do
    [
      defmodule BoutiqueSuggestions do
        def get_combinations(tops, bottoms, options \\ []) do
          maximum_price = Keyword.get(options, :maximum_price, 100.00)

          for top <- tops,
              bottom <- bottoms,
              top.base_color != bottom.base_color,
              top.price + bottom.price <= maximum_price do
            {top, bottom}
          end
        end
      end,
      defmodule BoutiqueSuggestions do
        def get_combinations(tops, bottoms, options \\ []) do
          maximum_price = Keyword.get(options, :maximum_price, 100.00)

          for top_item <- tops,
              bottom_item <- bottoms,
              top_item.price <= maximum_price - bottom_item.price,
              top_item.base_color != bottom_item.base_color do
            {top_item, bottom_item}
          end
        end
      end,
      defmodule BoutiqueSuggestions do
        def get_combinations(tops, bottoms, options \\ []) do
          maximum_price = Keyword.get(options, :maximum_price, 100.00)

          for top_item <- tops,
              bottom_item <- bottoms,
              top_item.price <= maximum_price - bottom_item.price &&
                top_item.base_color != bottom_item.base_color do
            {top_item, bottom_item}
          end
        end
      end
    ]
  end

  test_exercise_analysis "usage of list comprehensions is required",
    comments: [Constants.boutique_suggestions_use_list_comprehensions()] do
    defmodule BoutiqueSuggestions do
      def get_combinations(tops, bottoms, options \\ []) do
        get_all_combinations(tops, bottoms, [])
        |> filter_combinations(options)
        |> reverse([])
      end

      defp get_all_combinations([], bottoms, acc), do: acc

      defp get_all_combinations([top | tops], bottoms, acc) do
        get_all_combinations(tops, bottoms, get_all_combinations_with_a_top(top, bottoms, acc))
      end

      defp get_all_combinations_with_a_top(top, [], acc), do: acc

      defp get_all_combinations_with_a_top(top, [bottom | bottoms], acc) do
        get_all_combinations_with_a_top(top, bottoms, [{top, bottom} | acc])
      end

      defp filter_combinations([], _), do: []

      defp filter_combinations([{top, bottom} | rest], options) do
        maximum_price = Keyword.get(options, :maximum_price, 100.00)

        if top.base_color != bottom.base_color &&
             top.price + bottom.price <= maximum_price do
          [{top, bottom} | filter_combinations(rest, options)]
        else
          filter_combinations(rest, options)
        end
      end

      defp reverse([], acc), do: acc
      defp reverse([h | t], acc), do: reverse(t, [h | acc])
    end
  end

  describe "forbids any method of iteration other than list comprehensions" do
    test_exercise_analysis "detects Enum",
      comments: [Constants.boutique_suggestions_use_list_comprehensions()] do
      [
        defmodule BoutiqueSuggestions do
          def get_combinations(tops, bottoms, options \\ []) do
            maximum_price = Keyword.get(options, :maximum_price, 100.00)

            combinations =
              for top <- tops,
                  bottom <- bottoms do
                {top, bottom}
              end

            Enum.filter(combinations, fn {top, bottom} ->
              top.base_color != bottom.base_color &&
                top.price + bottom.price <= maximum_price
            end)
          end
        end,
        defmodule BoutiqueSuggestions do
          import Enum

          def get_combinations(tops, bottoms, options \\ []) do
            maximum_price = Keyword.get(options, :maximum_price, 100.00)

            combinations =
              for top <- tops,
                  bottom <- bottoms do
                {top, bottom}
              end

            filter(combinations, fn {top, bottom} ->
              top.base_color != bottom.base_color &&
                top.price + bottom.price <= maximum_price
            end)
          end
        end,
        defmodule BoutiqueSuggestions do
          alias Enum, as: E

          def get_combinations(tops, bottoms, options \\ []) do
            maximum_price = Keyword.get(options, :maximum_price, 100.00)

            combinations =
              for top <- tops,
                  bottom <- bottoms do
                {top, bottom}
              end

            E.filter(combinations, fn {top, bottom} ->
              top.base_color != bottom.base_color &&
                top.price + bottom.price <= maximum_price
            end)
          end
        end
      ]
    end

    test_exercise_analysis "detects List",
      comments: [Constants.boutique_suggestions_use_list_comprehensions()] do
      [
        defmodule BoutiqueSuggestions do
          def get_combinations(tops, bottoms, options \\ []) do
            maximum_price = Keyword.get(options, :maximum_price, 100.00)

            combinations =
              for top <- tops,
                  bottom <- bottoms do
                {top, bottom}
              end

            List.foldr(combinations, [], fn {top, bottom} = pair, acc ->
              if top.base_color != bottom.base_color && top.price + bottom.price <= maximum_price do
                [pair | acc]
              else
                acc
              end
            end)
          end
        end,
        defmodule BoutiqueSuggestions do
          import List

          def get_combinations(tops, bottoms, options \\ []) do
            maximum_price = Keyword.get(options, :maximum_price, 100.00)

            combinations =
              for top <- tops,
                  bottom <- bottoms do
                {top, bottom}
              end

            foldr(combinations, [], fn {top, bottom} = pair, acc ->
              if top.base_color != bottom.base_color && top.price + bottom.price <= maximum_price do
                [pair | acc]
              else
                acc
              end
            end)
          end
        end,
        defmodule BoutiqueSuggestions do
          alias List, as: TotallyNotList

          def get_combinations(tops, bottoms, options \\ []) do
            maximum_price = Keyword.get(options, :maximum_price, 100.00)

            combinations =
              for top <- tops,
                  bottom <- bottoms do
                {top, bottom}
              end

            TotallyNotList.foldr(combinations, [], fn {top, bottom} = pair, acc ->
              if top.base_color != bottom.base_color && top.price + bottom.price <= maximum_price do
                [pair | acc]
              else
                acc
              end
            end)
          end
        end
      ]
    end

    test_exercise_analysis "detects Stream",
      comments: [Constants.boutique_suggestions_use_list_comprehensions()] do
      [
        defmodule BoutiqueSuggestions do
          def get_combinations(tops, bottoms, options \\ []) do
            maximum_price = Keyword.get(options, :maximum_price, 100.00)

            combinations =
              for top <- tops,
                  bottom <- bottoms do
                {top, bottom}
              end

            stream =
              Stream.filter(combinations, fn {top, bottom} ->
                top.base_color != bottom.base_color &&
                  top.price + bottom.price <= maximum_price
              end)

            for x <- stream, do: x
          end
        end,
        defmodule BoutiqueSuggestions do
          import Stream

          def get_combinations(tops, bottoms, options \\ []) do
            maximum_price = Keyword.get(options, :maximum_price, 100.00)

            combinations =
              for top <- tops,
                  bottom <- bottoms do
                {top, bottom}
              end

            stream =
              filter(combinations, fn {top, bottom} ->
                top.base_color != bottom.base_color &&
                  top.price + bottom.price <= maximum_price
              end)

            for x <- stream, do: x
          end
        end,
        defmodule BoutiqueSuggestions do
          alias Stream, as: S

          def get_combinations(tops, bottoms, options \\ []) do
            maximum_price = Keyword.get(options, :maximum_price, 100.00)

            combinations =
              for top <- tops,
                  bottom <- bottoms do
                {top, bottom}
              end

            stream =
              S.filter(combinations, fn {top, bottom} ->
                top.base_color != bottom.base_color &&
                  top.price + bottom.price <= maximum_price
              end)

            for x <- stream, do: x
          end
        end
      ]
    end
  end
end
