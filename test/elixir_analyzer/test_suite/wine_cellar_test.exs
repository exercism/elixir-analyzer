defmodule ElixirAnalyzer.ExerciseTest.WineCellarTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.WineCellar

  test_exercise_analysis "example solution",
    comments: [] do
    [
      defmodule WineCellar do
        def filter(cellar, color, opts \\ []) do
          wines = Keyword.get_values(cellar, color)
          year = Keyword.get(opts, :year)
          country = Keyword.get(opts, :country)

          wines = if year, do: filter_by_year(wines, year), else: wines
          if country, do: filter_by_country(wines, country), else: wines
        end
      end,
      defmodule WineCellar do
        def filter(cellar, color, opts \\ [])

        def filter(cellar, color, []), do: Keyword.get_values(cellar, color)

        def filter(cellar, color, [{:year, year} | opts]) do
          cellar
          |> filter(color, opts)
          |> filter_by_year(year)
        end

        def filter(cellar, color, [{:country, country} | opts]) do
          cellar
          |> filter(color, opts)
          |> filter_by_country(country)
        end
      end
    ]
  end

  test_exercise_analysis "requires usage of Keyword.get_values/2",
    comments: [Constants.wine_cellar_use_keyword_get_values()] do
    [
      defmodule WineCellar do
        def filter(cellar, color, opts \\ []) do
          cellar
          |> filter_by_color(color)
          |> optional_filter_by_year(Keyword.get(opts, :year))
          |> optional_filter_by_country(Keyword.get(opts, :country))
        end

        defp filter_by_color([], _), do: []

        defp(filter_by_color([{color, wine} | tail], color)) do
          [wine | filter_by_color(tail, color)]
        end

        defp filter_by_color([{_, _} | tail], color) do
          filter_by_color(tail, color)
        end
      end,
      defmodule WineCellar do
        def filter(cellar, color, opts \\ []) do
          wines =
            for {^color, wine} <- cellar do
              wine
            end

          opts
          |> Enum.reduce(wines, fn
            {:year, year}, wines -> filter_by_year(wines, year)
            {:country, country}, wines -> filter_by_country(wines, country)
          end)
        end
      end
    ]
  end
end
