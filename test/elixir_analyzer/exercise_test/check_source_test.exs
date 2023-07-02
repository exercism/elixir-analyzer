defmodule ElixirAnalyzer.ExerciseTest.CheckSourceTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.Support.AnalyzerVerification.CheckSource

  alias ElixirAnalyzer.Submission

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
      ~S'''
      defmodule CheckSourceVerification do
        def foo do
          ~c"""
          love
          is
          all
          you
          need
          """
        end
      end
      '''
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

  test "full check_source definition in a test file for coverage" do
    defmodule Coverage do
      use ElixirAnalyzer.ExerciseTest

      check_source "check" do
        comment "this is a comment"

        check(_) do
          true
        end
      end

      check_source "some other check" do
        comment "this is another comment"
        suppress_if "check", :pass

        check(_) do
          false
        end
      end
    end

    defmodule CoverageTest do
      use ElixirAnalyzer.ExerciseTestCase,
        exercise_test_module: Coverage

      test_exercise_analysis "test check",
        comments: ["this is a comment"] do
        defmodule Module do
        end
      end
    end
  end

  describe "incorrect use raises errors" do
    unsupported =
      "Unsupported expression `unsupported`.\nThe macro `check_source` supports expressions: comment, type, suppress_if, check.\n"

    assert_raise RuntimeError, unsupported, fn ->
      defmodule Failure do
        use ElixirAnalyzer.ExerciseTest

        check_source "check" do
          comment "this will fail"
          unsupported(:woops)

          check(_) do
            true
          end
        end
      end
    end

    assert_raise RuntimeError, "Comment must be defined for each check_source test", fn ->
      defmodule Failure do
        use ElixirAnalyzer.ExerciseTest

        check_source "check" do
          type :informative

          check(_) do
            true
          end
        end
      end
    end

    wrong_type =
      "Unsupported type `unsupported`.\nThe macro `check_source` supports the following types: essential, actionable, informative, celebratory.\n"

    assert_raise RuntimeError, wrong_type, fn ->
      defmodule Failure do
        use ElixirAnalyzer.ExerciseTest

        check_source "check" do
          type :unsupported

          check(_) do
            true
          end
        end
      end
    end
  end

  test "allows passing comment params" do
    code_string = ~S"""
    defmodule Fruits do
      @best_fruit = "banana"
      @best_fruit_for_breakfast = "banana"
      @best_fruit_for_a_snack = "banana"
    end
    """

    source =
      ElixirAnalyzer.ExerciseTestCase.find_source(
        ElixirAnalyzer.Support.AnalyzerVerification.CheckSource
      )

    result =
      ElixirAnalyzer.Support.AnalyzerVerification.CheckSource.analyze(%Submission{
        source: %{source | code_string: code_string},
        analysis_module: ElixirAnalyzer.Support.AnalyzerVerification.CheckSource
      })

    comment = Enum.find(result.comments, fn comment -> comment.comment == "even banana count" end)

    assert comment == %{
             comment: "even banana count",
             params: %{banana_count: 3},
             type: :actionable
           }
  end
end
