# credo:disable-for-this-file Credo.Check.Readability.VariableNames
# credo:disable-for-this-file Credo.Check.Readability.FunctionNames
# credo:disable-for-this-file Credo.Check.Readability.ModuleAttributeNames

defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.VariableNamesTest do
  use ExUnit.Case
  alias ElixirAnalyzer.Comment
  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.ExerciseTest.CommonChecks.VariableNames

  @moduledoc """
  Tests that variables are in snake_case
  tests taken and adapted from
  https://github.com/rrrene/credo/blob/master/test/credo/check/readability/variable_names_test.exs
  """

  describe "valid variable names" do
    test "it should NOT report expected code" do
      code =
        quote do
          defmodule CredoSampleModule do
            def some_function(parameter1, parameter2) do
              some_value = parameter1 + parameter2
              {some_value, _} = parameter1
              [1, some_value] = parameter1
              [some_value | tail] = parameter1
              "e" <> some_value = parameter1
              ^some_value = parameter1
              %{some_value: some_value} = parameter1
              ... = parameter1
              latency_μs = 5
              user = %__MODULE__{}
              :math.pow(__DIR__)
              some_value.(__ENV__)
            end

            defmacro foo() do
              some_function(__CALLER__, __STACKTRACE__)
            end
          end
        end

      assert VariableNames.run(code) == []
    end
  end

  describe "invalid variable names" do
    test "it should report a violation" do
      code =
        quote do
          defmodule CredoSampleModule do
            def some_function(parameter1, parameter2) do
              someValue = parameter1 + parameter2
            end
          end
        end

      assert VariableNames.run(code) == [
               {:fail,
                %Comment{
                  type: :actionable,
                  name: Constants.solution_variable_name_snake_case(),
                  comment: Constants.solution_variable_name_snake_case(),
                  params: %{expected: "some_value", actual: "someValue"}
                }}
             ]
    end

    test "it should report a violation /2" do
      code =
        quote do
          defmodule CredoSampleModule do
            def some_function(parameter1, parameter2) do
              someOtherValue = parameter1 + parameter2
            end
          end
        end

      assert VariableNames.run(code) == [
               {:fail,
                %Comment{
                  type: :actionable,
                  name: Constants.solution_variable_name_snake_case(),
                  comment: Constants.solution_variable_name_snake_case(),
                  params: %{expected: "some_other_value", actual: "someOtherValue"}
                }}
             ]
    end

    test "it should report a violation /3" do
      code =
        quote do
          defmodule CredoSampleModule do
            def some_function(parameter1, parameter2) do
              {true, someValue} = parameter1
            end
          end
        end

      assert VariableNames.run(code) == [
               {:fail,
                %Comment{
                  type: :actionable,
                  name: Constants.solution_variable_name_snake_case(),
                  comment: Constants.solution_variable_name_snake_case(),
                  params: %{expected: "some_value", actual: "someValue"}
                }}
             ]
    end

    test "it should report a violation /4" do
      code =
        quote do
          defmodule CredoSampleModule do
            def some_function(parameter1, parameter2) do
              [1, someValue] = parameter1
            end
          end
        end

      assert VariableNames.run(code) == [
               {:fail,
                %Comment{
                  type: :actionable,
                  name: Constants.solution_variable_name_snake_case(),
                  comment: Constants.solution_variable_name_snake_case(),
                  params: %{expected: "some_value", actual: "someValue"}
                }}
             ]
    end

    test "it should report a violation /5" do
      code =
        quote do
          defmodule CredoSampleModule do
            def some_function(parameter1, parameter2) do
              [someValue | tail] = parameter1
            end
          end
        end

      assert VariableNames.run(code) == [
               {:fail,
                %Comment{
                  type: :actionable,
                  name: Constants.solution_variable_name_snake_case(),
                  comment: Constants.solution_variable_name_snake_case(),
                  params: %{expected: "some_value", actual: "someValue"}
                }}
             ]
    end

    test "it should report a violation /6" do
      code =
        quote do
          defmodule CredoSampleModule do
            def some_function(parameter1, parameter2) do
              "e" <> someValue = parameter1
            end
          end
        end

      assert VariableNames.run(code) == [
               {:fail,
                %Comment{
                  type: :actionable,
                  name: Constants.solution_variable_name_snake_case(),
                  comment: Constants.solution_variable_name_snake_case(),
                  params: %{expected: "some_value", actual: "someValue"}
                }}
             ]
    end

    test "it should report a violation /7" do
      code =
        quote do
          defmodule CredoSampleModule do
            def some_function(parameter1, parameter2) do
              ^someValue = parameter1
            end
          end
        end

      assert VariableNames.run(code) == [
               {:fail,
                %Comment{
                  type: :actionable,
                  name: Constants.solution_variable_name_snake_case(),
                  comment: Constants.solution_variable_name_snake_case(),
                  params: %{expected: "some_value", actual: "someValue"}
                }}
             ]
    end

    test "it should report a violation /8" do
      code =
        quote do
          defmodule CredoSampleModule do
            def some_function(parameter1, parameter2) do
              %{some_value: someValue} = parameter1
            end
          end
        end

      assert VariableNames.run(code) == [
               {:fail,
                %Comment{
                  type: :actionable,
                  name: Constants.solution_variable_name_snake_case(),
                  comment: Constants.solution_variable_name_snake_case(),
                  params: %{expected: "some_value", actual: "someValue"}
                }}
             ]
    end

    test "it should report a violation /9" do
      code =
        quote do
          defmodule CredoSampleModule do
            def some_function(oneParam, twoParam) do
              :ok
            end
          end
        end

      assert VariableNames.run(code) == [
               {:fail,
                %Comment{
                  type: :actionable,
                  name: Constants.solution_variable_name_snake_case(),
                  comment: Constants.solution_variable_name_snake_case(),
                  params: %{expected: "one_param", actual: "oneParam"}
                }}
             ]
    end

    test "it should report a violation /10" do
      code =
        quote do
          defmodule CredoSampleModule do
            def some_function(param, p2, p3) do
              [someValue + v2 + v3 | {someValue} <- param, v2 <- p2, v3 <- p3]
            end
          end
        end

      assert VariableNames.run(code) == [
               {:fail,
                %Comment{
                  type: :actionable,
                  name: Constants.solution_variable_name_snake_case(),
                  comment: Constants.solution_variable_name_snake_case(),
                  params: %{expected: "some_value", actual: "someValue"}
                }}
             ]
    end

    test "it should report a violation /11" do
      code =
        quote do
          defmodule CredoSampleModule do
            def some_function(param) do
              for someValue <- param do
                someValue + 1
              end
            end
          end
        end

      assert VariableNames.run(code) == [
               {:fail,
                %Comment{
                  type: :actionable,
                  name: Constants.solution_variable_name_snake_case(),
                  comment: Constants.solution_variable_name_snake_case(),
                  params: %{expected: "some_value", actual: "someValue"}
                }}
             ]
    end

    test "it should report a violation /12" do
      code =
        quote do
          defmodule CredoSampleModule do
            def some_function(param) do
              case param do
                0 -> :ok
                1 -> :ok
                someValue -> :error
              end
            end
          end
        end

      assert VariableNames.run(code) == [
               {:fail,
                %Comment{
                  type: :actionable,
                  name: Constants.solution_variable_name_snake_case(),
                  comment: Constants.solution_variable_name_snake_case(),
                  params: %{expected: "some_value", actual: "someValue"}
                }}
             ]
    end

    test "it should report a violation /13" do
      code =
        quote do
          defmodule CredoSampleModule do
            def some_function(_param) do
              try do
                raise "oops"
              catch
                someValue -> :error
              end
            end
          end
        end

      assert VariableNames.run(code) == [
               {:fail,
                %Comment{
                  type: :actionable,
                  name: Constants.solution_variable_name_snake_case(),
                  comment: Constants.solution_variable_name_snake_case(),
                  params: %{expected: "some_value", actual: "someValue"}
                }}
             ]
    end

    test "it should report a violation /14" do
      code =
        quote do
          defmodule CredoSampleModule do
            def some_function(param) do
              receive do
                {:get, someJam} -> :ok
                {:put, ^param} -> :ok
              end
            end
          end
        end

      assert VariableNames.run(code) == [
               {:fail,
                %Comment{
                  type: :actionable,
                  name: Constants.solution_variable_name_snake_case(),
                  comment: Constants.solution_variable_name_snake_case(),
                  params: %{expected: "some_jam", actual: "someJam"}
                }}
             ]
    end

    test "it should report a violation /15" do
      code =
        quote do
          defmodule CredoSampleModule do
            def some_function(timeOut) do
              receive do
                _ -> :ok
              after
                timeOut -> :timeout
              end
            end
          end
        end

      assert VariableNames.run(code) == [
               {:fail,
                %Comment{
                  type: :actionable,
                  name: Constants.solution_variable_name_snake_case(),
                  comment: Constants.solution_variable_name_snake_case(),
                  params: %{expected: "time_out", actual: "timeOut"}
                }}
             ]
    end

    test "it should report a violation /16" do
      code =
        quote do
          defmodule CredoSampleModule do
            def some_function(param) do
              fn otherParam -> param + otherParam end
            end
          end
        end

      assert VariableNames.run(code) == [
               {:fail,
                %Comment{
                  type: :actionable,
                  name: Constants.solution_variable_name_snake_case(),
                  comment: Constants.solution_variable_name_snake_case(),
                  params: %{expected: "other_param", actual: "otherParam"}
                }}
             ]
    end

    test "it should report a violation /17" do
      code =
        quote do
          defmodule CredoSampleModule do
            def some_function(param) do
              with {:ok, v1} <- M.f1(param),
                   {:ok, v2} <- M.f2(v1),
                   {:ok, someValue} <- M.f3(v2),
                   do: M.f0(someValue)
            end
          end
        end

      assert VariableNames.run(code) == [
               {:fail,
                %Comment{
                  type: :actionable,
                  name: Constants.solution_variable_name_snake_case(),
                  comment: Constants.solution_variable_name_snake_case(),
                  params: %{expected: "some_value", actual: "someValue"}
                }}
             ]
    end

    test "it should report a violation /18" do
      code =
        quote do
          defmodule CredoSampleModule do
            def some_function(parameter1, parameter2) do
              %{some_value: someValue, other_value: otherValue} = parameter1
            end
          end
        end

      assert VariableNames.run(code) == [
               {:fail,
                %Comment{
                  type: :actionable,
                  name: Constants.solution_variable_name_snake_case(),
                  comment: Constants.solution_variable_name_snake_case(),
                  params: %{expected: "some_value", actual: "someValue"}
                }}
             ]
    end
  end

  describe "unrelated code" do
    test "it should NOT report function names" do
      code =
        quote do
          defmodule User do
            def firstName(user), do: user.first_name
            defp registeredInLastQuarter?(user), do: true
            defmacro validateUser!(user), do: true
            defmacrop doValidateUser(user), do: true
          end
        end

      assert VariableNames.run(code) == []
    end

    test "it should NOT report function names when no arg and missing parenthesis" do
      code =
        quote do
          defmodule User do
            def firstName, do: nil
            defp registeredInLastQuarter?, do: true
            defmacro validateUser!, do: true
            defmacrop doValidateUser, do: true
          end
        end

      assert VariableNames.run(code) == []
    end

    test "it should NOT report module attribute names" do
      code =
        quote do
          defmodule CredoSampleModule do
            @someModuleAttribute 7
          end
        end

      assert VariableNames.run(code) == []
    end
  end
end
