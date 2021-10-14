defmodule ElixirAnalyzer.ExerciseTest.CheckSourceTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.Support.AnalyzerVerification.CheckSource

  test_exercise_analysis "empty module",
    comments: ["always return false", "didn't use multiline"] do
    ~S"""
    defmodule CheckSourceVerification do
    end
    """
  end

  test_exercise_analysis "contains integer literals",
    comments: [
      "always return false",
      "used integer literal from ?a to ?z",
      "didn't use multiline"
    ] do
    ~S"""
    defmodule CheckSourceVerification do
      def foo(x) do
        case x do
          97 -> "a"
          98 -> "b"
          _ -> "z"
        end
      end
    end
    """
  end

  test_exercise_analysis "contains integer but false positive",
    comments: [
      "always return false",
      "used integer literal from ?a to ?z",
      "didn't use multiline"
    ] do
    ~S"""
    defmodule CheckSourceVerification do
      def best_version(game) do
        case game do
          "fifa" -> "fifa 98"
          "tomb raider" -> "tomb raider II (1997)"
          _ -> "goat simulator"
        end
      end
    end
    """
  end

  test_exercise_analysis "uses multiline strings",
    comments: ["always return false"] do
    [
      ~S'''
      defmodule CheckSourceVerification do
        @moduledoc """
        this module doesn't do much
        """
      end
      ''',
      ~S'''
      defmodule CheckSourceVerification do
        def foo do
          """
          all
          you
          need
          is
          love
          """
        end
      end
      ''',
      ~S"""
      defmodule CheckSourceVerification do
        def foo do
          '''
          love
          is
          all
          you
          need
          '''
        end
      end
      """
    ]
  end

  test_exercise_analysis "short module",
    comments: ["always return false", "module is too short", "didn't use multiline"] do
    ~S"""
    defmodule C do
    end
    """
  end

  test_exercise_analysis "badly formatted modules",
    comments: ["always return false", "didn't use multiline", "module is not formatted"] do
    [
      ~S"""
      defmodule CheckSourceVerification do
                                    def foo(), do: :ok
      end
      """,
      ~S"""
      defmodule CheckSourceVerification do



      def foo, do: :ok

      end
      """,
      ~S"""
      defmodule    CheckSourceVerification     do
      end
      """,
      ~S"""
      defmodule CheckSourceVerification do end
      """
    ]
  end
end
