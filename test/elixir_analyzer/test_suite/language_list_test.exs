defmodule ElixirAnalyzer.ExerciseTest.LanguageListTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.LanguageList

  test_exercise_analysis "example solution",
    comments: [] do
    defmodule LanguageList do
      def new, do: []

      def add(list, language), do: [language | list]

      def remove([_removed_language | list]), do: list

      def first([first_language | _list]), do: first_language

      def count(list), do: length(list)

      def exciting_list?(list), do: "Elixir" in list
    end
  end

  test_exercise_analysis "forbids usage of the Enum",
    comments: [Constants.language_list_do_not_use_enum()] do
    [
      defmodule LanguageList do
        def first(list), do: Enum.at(list, 0)
      end,
      defmodule LanguageList do
        import Enum
        def first(list), do: at(list, 0)
      end,
      defmodule LanguageList do
        import Enum, only: [at: 2]
        def first(list), do: at(list, 0)
      end,
      defmodule LanguageList do
        alias Enum, as: E
        def first(list), do: E.at(list, 0)
      end,
      defmodule LanguageList do
        def count(list), do: Enum.count(list)
      end,
      defmodule LanguageList do
        import Enum
        def count(list), do: count(list)
      end,
      defmodule LanguageList do
        import Enum, only: [count: 1]
        def count(list), do: count(list)
      end,
      defmodule LanguageList do
        alias Enum, as: E
        def count(list), do: E.count(list)
      end,
      defmodule LanguageList do
        def exciting_list?(list), do: Enum.any?(list, &(&1 == "Elixir"))
      end,
      defmodule LanguageList do
        def exciting_list?(list), do: Enum.filter(list, &(&1 == "Elixir")) != []
      end,
      defmodule LanguageList do
        import Enum
        def exciting_list?(list), do: any?(list, &(&1 == "Elixir"))
      end,
      defmodule LanguageList do
        import Enum, only: [any?: 2]
        def exciting_list?(list), do: any?(list, &(&1 == "Elixir"))
      end,
      defmodule LanguageList do
        alias Enum, as: E
        def exciting_list?(list), do: E.any?(list, &(&1 == "Elixir"))
      end
    ]
  end
end
