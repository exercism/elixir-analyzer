defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.CommentsTest do
  use ExUnit.Case
  alias ElixirAnalyzer.Comment
  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.ExerciseTest.CommonChecks.Comments

  test "code without comments" do
    string = """
    defmodule KitchenCalculator do
      def get_volume(volume_pair) do
        elem(volume_pair, 1)
      end
    end
    """

    ast = Code.string_to_quoted!(string)

    assert Comments.run(ast, string) == []
  end

  describe "finding our boilerplate comments" do
    test "kitchen calculator boilerplate" do
      string = """
      defmodule KitchenCalculator do
        def get_volume(volume_pair) do
          # Please implement the get_volume/1 function
          elem(volume_pair, 1)
        end
      end
      """

      ast = Code.string_to_quoted!(string)

      assert Comments.run(ast, string) == [
               {:fail,
                %Comment{
                  type: :actionable,
                  name: Constants.solution_boilerplate_comment(),
                  comment: Constants.solution_boilerplate_comment()
                }}
             ]
    end

    test "lasagna boilerplate" do
      string = """
      defmodule Lasagna do
        # Please define the 'expected_minutes_in_oven/0' function
        def expected_minutes_in_oven() do
          40
        end
      end
      """

      ast = Code.string_to_quoted!(string)

      assert Comments.run(ast, string) == [
               {:fail,
                %Comment{
                  type: :actionable,
                  name: Constants.solution_boilerplate_comment(),
                  comment: Constants.solution_boilerplate_comment()
                }}
             ]
    end

    test "it returns a single comment even when there are multiple matches" do
      string = """
      defmodule LibraryFees do
        def datetime_from_string(string) do
          # Please implement the datetime_from_string/1 function
        end

        def before_noon?(datetime) do
          # Please implement the before_noon?/1 function
        end

        def return_date(checkout_datetime) do
          # Please implement the return_date/1 function
        end
      end
      """

      ast = Code.string_to_quoted!(string)

      assert Comments.run(ast, string) == [
               {:fail,
                %Comment{
                  type: :actionable,
                  name: Constants.solution_boilerplate_comment(),
                  comment: Constants.solution_boilerplate_comment()
                }}
             ]
    end

    test "it's case insensitive" do
      string = """
      defmodule Lasagna do
        # PLEASE define the 'expected_minutes_in_oven/0' function
        def expected_minutes_in_oven() do
          40
        end
      end
      """

      ast = Code.string_to_quoted!(string)

      assert Comments.run(ast, string) == [
               {:fail,
                %Comment{
                  type: :actionable,
                  name: Constants.solution_boilerplate_comment(),
                  comment: Constants.solution_boilerplate_comment()
                }}
             ]
    end

    test "it only detect the key phrase in a comment, not in a string" do
      string = """
      defmodule KitchenCalculator do
        def get_volume(volume_pair) do
          "# Please implement the get_volume/1 function"
          elem(volume_pair, 1)
        end
      end
      """

      ast = Code.string_to_quoted!(string)

      assert Comments.run(ast, string) == []
    end
  end

  describe "finding student's own TODO comments" do
    test "detects TODO comments" do
      string = """
      defmodule KitchenCalculator do
        def get_volume(volume_pair) do
          # TODO: use pattern matching here
          elem(volume_pair, 1)
        end
      end
      """

      ast = Code.string_to_quoted!(string)

      assert Comments.run(ast, string) == [
               {:fail,
                %Comment{
                  type: :informative,
                  name: Constants.solution_todo_comment(),
                  comment: Constants.solution_todo_comment()
                }}
             ]
    end

    test "detects FIXME comments" do
      string = """
      defmodule KitchenCalculator do
        def get_volume(x) do
          # FIXME find better variable name
          elem(x, 1)
        end
      end
      """

      ast = Code.string_to_quoted!(string)

      assert Comments.run(ast, string) == [
               {:fail,
                %Comment{
                  type: :informative,
                  name: Constants.solution_todo_comment(),
                  comment: Constants.solution_todo_comment()
                }}
             ]
    end

    test "it returns a single comment even when there are multiple matches" do
      string = """
      defmodule KitchenCalculator do
        def get_volume(x) do
          # TODO find better variable name
          elem(x, 1)
        end

        # FIXME reformat to single line functions
        def to_milliliter({:cup, cups}) do
          {:milliliter, cups * 240}
        end

        def to_milliliter({:fluid_ounce, floz}) do
          {:milliliter, floz * 30}
        end
      end
      """

      ast = Code.string_to_quoted!(string)

      assert Comments.run(ast, string) == [
               {:fail,
                %Comment{
                  type: :informative,
                  name: Constants.solution_todo_comment(),
                  comment: Constants.solution_todo_comment()
                }}
             ]
    end

    test "it's case insensitive" do
      string = """
      defmodule KitchenCalculator do
        def get_volume(x) do
          # todo find better variable name
          elem(x, 1)
        end
      end
      """

      ast = Code.string_to_quoted!(string)

      assert Comments.run(ast, string) == [
               {:fail,
                %Comment{
                  type: :informative,
                  name: Constants.solution_todo_comment(),
                  comment: Constants.solution_todo_comment()
                }}
             ]
    end

    test "it only detect the key phrase in a comment, not in a string" do
      string = """
      defmodule KitchenCalculator do
        def get_volume(volume_pair) do
          "# TODO: use pattern matching here"
          elem(volume_pair, 1)
        end
      end
      """

      ast = Code.string_to_quoted!(string)

      assert Comments.run(ast, string) == []
    end
  end

  describe "finding our boilerplate comments and finding student's own TODO comments" do
    test "it's case insensitive" do
      string = """
      defmodule KitchenCalculator do
        def get_volume(x) do
          # Please implement the get_volume/1 function
          # todo find better variable name
          elem(x, 1)
        end
      end
      """

      ast = Code.string_to_quoted!(string)

      assert Comments.run(ast, string) == [
               {:fail,
                %Comment{
                  type: :actionable,
                  name: Constants.solution_boilerplate_comment(),
                  comment: Constants.solution_boilerplate_comment()
                }},
               {:fail,
                %Comment{
                  type: :informative,
                  name: Constants.solution_todo_comment(),
                  comment: Constants.solution_todo_comment()
                }}
             ]
    end
  end
end
