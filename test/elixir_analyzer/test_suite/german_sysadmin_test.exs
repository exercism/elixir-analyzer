defmodule ElixirAnalyzer.ExerciseTest.GermanSysadminTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.GermanSysadmin

  test_exercise_analysis "example solution",
    comments: [ElixirAnalyzer.Constants.solution_same_as_exemplar()] do
    ~S"""
    defmodule Username do
      def sanitize(~c"") do
        ~c""
      end

      def sanitize([head | tail]) do
        sanitized =
          case head do
            ?ß -> ~c"ss"
            ?ä -> ~c"ae"
            ?ö -> ~c"oe"
            ?ü -> ~c"ue"
            x when x >= ?a and x <= ?z -> [x]
            ?_ -> ~c"_"
            _ -> ~c""
          end

        sanitized ++ sanitize(tail)
      end
    end
    """
  end

  test_exercise_analysis "other valid solutions",
    comments: [] do
    [
      ~S"""
      defmodule Username do
        def sanitize(list) do
          List.foldr(list, [], fn code, acc ->
            sanitized =
              case code do
                # 223
                ?ß -> ~c"ss"
                ?ä -> ~c"ae"
                ?ö -> ~c"oe"
                ?ü -> ~c"ue"
                x when x >= ?a and x <= ?z -> [x]
                ?_ -> ~c"_"
                _ -> ~c""
              end

            sanitized ++ acc
          end)
        end
      end
      """,
      """
      defmodule Username do
      @spec sanitize(charlist) :: charlist
      def sanitize(username) do
        username
        |> Enum.filter(&(&1 in ~c"äöüßabcdefghijklmnopqrstuvwxyz_"))
        |> Enum.reduce([], fn char, list ->
          case char do
            ?ä -> [?e, ?a | list]
            ?ö -> [?e, ?o | list]
            ?ü -> [?e, ?u | list]
            ?ß -> [?s, ?s | list]
            c -> [c | list]
          end
        end)
        |> Enum.reverse()
      end
      end
      """
    ]
  end

  test_exercise_analysis "detects cheating with strings",
    comments: [
      Constants.german_sysadmin_no_string(),
      Constants.solution_no_integer_literal()
    ] do
    ~S"""
    defmodule Username do
      def sanitize(charlist) do
        charlist
        |> Enum.filter(&(&1 < 0xD800))
        |> to_string()
        |> String.split("", trim: true)
        |> Enum.map(fn letter ->
          case letter do
            "ß" ->
              "ss"

            "ä" ->
              "ae"

            "ö" ->
              "oe"

            "ü" ->
              "ue"

            letter when letter in ~w(a b c d e f g h i j k l m n o p q r s t u v w x y z) ->
              letter

            "_" ->
              "_"

            _ ->
              ""
          end
        end)
        |> Enum.join("")
        |> to_charlist()
      end
    end
    """
  end

  test_exercise_analysis "detects cheating with strings, with ?ß notation",
    comments: [Constants.german_sysadmin_no_string()] do
    ~S"""
    defmodule Username do
      def sanitize(list) do
        List.foldr(list, "", fn code, acc ->
          sanitized =
            case code do
              ?ß -> "ss"
              ?ä -> "ae"
              ?ö -> "oe"
              ?ü -> "ue"
              x when x >= ?a and x <= ?z -> <<x>>
              ?_ -> "_"
              _ -> ""
            end

          sanitized <> acc
        end)
        |> to_charlist()
      end
    end
    """
  end

  test_exercise_analysis "using case is required",
    comments: [Constants.german_sysadmin_use_case()] do
    [
      ~S"""
      defmodule Username do
        def sanitize('') do
          ''
        end

        def sanitize([head | tail]) do
          sanitized =
            cond do
              head == ?ß -> 'ss'
              head == ?ä -> 'ae'
              head == ?ö -> 'oe'
              head == ?ü -> 'ue'
              head >= ?a and head <= ?z -> [head]
              head == ?_ -> '_'
              true -> ''
            end

          sanitized ++ sanitize(tail)
        end
      end
      """,
      ~S"""
      defmodule Username do
        def sanitize('') do
          ''
        end

        def sanitize([head | tail]) do
          do_sanitize(head) ++ sanitize(tail)
        end

        defp do_sanitize(?ß), do: 'ss'
        defp do_sanitize(?ä), do: 'ae'
        defp do_sanitize(?ö), do: 'oe'
        defp do_sanitize(?ü), do: 'ue'
        defp do_sanitize(?_), do: '_'
        defp do_sanitize(x) when x >= ?a and x <= ?z, do: [x]
        defp do_sanitize(x), do: []
      end
      """
    ]
  end

  test_exercise_analysis "detects integer literals",
    comments: [Constants.solution_no_integer_literal()] do
    ~S"""
    defmodule Username do
      def sanitize('') do
        ''
      end

      def sanitize([head | tail]) do
        sanitized =
          case head do
            252 -> 'ue'
            246 -> 'oe'
            228 -> 'ae'
            223 -> 'ss'
            x when x >= 97 and x <= 122 -> [x]
            95 -> '_'
            _ -> ''
          end

        sanitized ++ sanitize(tail)
      end
    end
    """
  end

  test_exercise_analysis "valid solution without quoting triggers comment",
    # This is because Elixir's ASTs don't differentiate between code points like ?ß and integers
    comments: [Constants.solution_no_integer_literal()] do
    defmodule Username do
      def sanitize(list) do
        List.foldr(list, [], fn code, acc ->
          sanitized =
            case code do
              ?ß -> ~c"ss"
              ?ä -> ~c"ae"
              ?ö -> ~c"oe"
              ?ü -> ~c"ue"
              x when x >= ?a and x <= ?z -> [x]
              ?_ -> ~c"_"
              _ -> ~c""
            end

          sanitized ++ acc
        end)
      end
    end
  end
end
