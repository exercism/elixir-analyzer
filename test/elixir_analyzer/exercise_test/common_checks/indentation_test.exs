defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.IndentationTest do
  use ExUnit.Case
  alias ElixirAnalyzer.Comment
  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.ExerciseTest.CommonChecks.Indentation

  describe "correct indentation" do
    test "correct indentation" do
      string = """
      defmodule User do
        def first_name(user) do
          user.first_name
        end
      end
      """

      ast = Code.string_to_quoted!(string)

      assert Indentation.run(ast, string) == []
    end

    test "wrong indentation but no tabs" do
      string = """
      defmodule User do
          def first_name(user) do
                  user.first_name
       end
      end
      """

      ast = Code.string_to_quoted!(string)

      assert Indentation.run(ast, string) == []
    end

    test "tabs used in strings" do
      string = """
      defmodule User do
        def first_name(user) do
          "\t\tMichael"
        end
      end
      """

      ast = Code.string_to_quoted!(string)

      assert Indentation.run(ast, string) == []
    end

    test "tabs used in strings escaped" do
      string = """
      defmodule User do
        def first_name(user) do
          "\\t\\tMichael"
        end
      end
      """

      ast = Code.string_to_quoted!(string)

      assert Indentation.run(ast, string) == []
    end

    test "tabs used in moduledoc" do
      string = """
      @moduledoc "\tsomething"
      """

      ast = Code.string_to_quoted!(string)

      assert Indentation.run(ast, string) == []
    end

    test "tabs used in a multiline moduledoc in its content" do
      string = """
      defmodule Foo do
        @moduledoc \"""
        \tfoo bar
        \"""
      end
      """

      ast = Code.string_to_quoted!(string)

      assert Indentation.run(ast, string) == []
    end
  end

  describe "incorrect indentation" do
    test "tabs used for indentation" do
      string = """
      defmodule User do
      \tdef first_name(user) do
      \t\tuser.first_name
      \tend
      end
      """

      ast = Code.string_to_quoted!(string)

      assert Indentation.run(ast, string) == [
               {:fail,
                %Comment{
                  type: :informative,
                  comment: Constants.solution_indentation()
                }}
             ]
    end

    test "tabs used for indentation and in string" do
      string = """
      defmodule User do
      \tdef first_name(user \\\\ "Tabby\tMc\tTab") do
      \t\tuser.first_name
      \tend
      end
      """

      ast = Code.string_to_quoted!(string)

      assert Indentation.run(ast, string) == [
               {:fail,
                %Comment{
                  type: :informative,
                  comment: Constants.solution_indentation()
                }}
             ]
    end

    test "tabs used for indentation and in string escaped" do
      string = """
      defmodule User do
      \tdef first_name(user \\\\ "Tabby\\tMc\\tTab") do
      \t\tuser.first_name
      \tend
      end
      """

      ast = Code.string_to_quoted!(string)

      assert Indentation.run(ast, string) == [
               {:fail,
                %Comment{
                  type: :informative,
                  comment: Constants.solution_indentation()
                }}
             ]
    end

    test "tabs used in a multiline moduledoc for indentation" do
      string = """
      defmodule Foo do
        @moduledoc \"""
      \tfoo bar
        \"""
      end
      """

      ast = Code.string_to_quoted!(string)

      assert Indentation.run(ast, string) == [
               {:fail,
                %Comment{
                  type: :informative,
                  comment: Constants.solution_indentation()
                }}
             ]
    end

    test "trailing tabs trigger the check too" do
      string = """
      defmodule User do
        def first_name(user) do\t
          user.first_name
        end
      end
      """

      ast = Code.string_to_quoted!(string)

      assert Indentation.run(ast, string) == [
               {:fail,
                %Comment{
                  type: :informative,
                  comment: Constants.solution_indentation()
                }}
             ]
    end
  end
end
