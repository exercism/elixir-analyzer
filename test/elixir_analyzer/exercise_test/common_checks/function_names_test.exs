# credo:disable-for-this-file Credo.Check.Readability.FunctionNames

defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.FunctionNamesTest do
  use ExUnit.Case
  alias ElixirAnalyzer.Comment
  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.ExerciseTest.CommonChecks.FunctionNames

  test "returns empty list if there are functions, macros, or guards" do
    code =
      quote do
        defmodule User do
          defstruct(:name, :email)
        end
      end

    assert FunctionNames.run(code) == []
  end

  test "doesn't crash when a variable is named def" do
    code =
      quote do
        defmodule User do
          def name(user) do
            def = user.first_name
            defmacro = user.last_name
            def <> " " <> defmacro
          end
        end
      end

    assert FunctionNames.run(code) == []
  end

  test "returns empty list if all names are correct" do
    code =
      quote do
        defmodule User do
          def first_name(user), do: user.first_name
          defp registered_in_last_quarter?(user), do: true
          defmacro validate_user!, do: true
          defmacrop do_validate_user, do: true
          defguard is_user when true
          defguardp is_registered_user when true
        end
      end

    assert FunctionNames.run(code) == []
  end

  test "returns an actionable comment with params" do
    code =
      quote do
        defmodule User do
          def firstName(user), do: user.first_name
        end
      end

    assert FunctionNames.run(code) == [
             {:fail,
              %Comment{
                type: :actionable,
                comment: Constants.solution_function_name_snake_case(),
                name: Constants.solution_function_name_snake_case(),
                params: %{
                  expected: "first_name",
                  actual: "firstName"
                }
              }}
           ]
  end

  test "works for def, defp, defmacro, defmacrop, defguard, and defguardp" do
    get_result = fn expected, actual ->
      [
        {:fail,
         %Comment{
           type: :actionable,
           comment: Constants.solution_function_name_snake_case(),
           name: Constants.solution_function_name_snake_case(),
           params: %{
             expected: expected,
             actual: actual
           }
         }}
      ]
    end

    code =
      quote do
        defmodule User do
          defp registeredInLastQuarter?(user), do: true
        end
      end

    assert FunctionNames.run(code) ==
             get_result.("registered_in_last_quarter?", "registeredInLastQuarter?")

    code =
      quote do
        defmodule User do
          defmacro validateUser!, do: true
        end
      end

    assert FunctionNames.run(code) == get_result.("validate_user!", "validateUser!")

    code =
      quote do
        defmodule User do
          defmacrop doValidateUser, do: true
        end
      end

    assert FunctionNames.run(code) == get_result.("do_validate_user", "doValidateUser")

    code =
      quote do
        defmodule User do
          defguard(isUser, do: true)
        end
      end

    assert FunctionNames.run(code) == get_result.("is_user", "isUser")

    code =
      quote do
        defmodule User do
          defguardp(isRegisteredUser, do: true)
        end
      end

    assert FunctionNames.run(code) == get_result.("is_registered_user", "isRegisteredUser")
  end

  test "only reports the first wrong name" do
    code =
      quote do
        defmodule User do
          def first_name(user), do: getFirstName(user)
          defguard isRegisteredUser(user) when true
          defp getFirstName(user), do: user.first_name
        end
      end

    assert FunctionNames.run(code) == [
             {:fail,
              %Comment{
                type: :actionable,
                comment: Constants.solution_function_name_snake_case(),
                name: Constants.solution_function_name_snake_case(),
                params: %{
                  expected: "is_registered_user",
                  actual: "isRegisteredUser"
                }
              }}
           ]
  end

  test "can handle function heads" do
    code =
      quote do
        defmodule User do
          def getName(user, fallback \\ "Doe")
        end
      end

    assert FunctionNames.run(code) == [
             {:fail,
              %Comment{
                type: :actionable,
                comment: Constants.solution_function_name_snake_case(),
                name: Constants.solution_function_name_snake_case(),
                params: %{
                  expected: "get_name",
                  actual: "getName"
                }
              }}
           ]
  end

  test "can handle guards" do
    code =
      quote do
        defmodule User do
          def getName(user, fallback) when is_bitstring(fallback)
        end
      end

    assert FunctionNames.run(code) == [
             {:fail,
              %Comment{
                type: :actionable,
                comment: Constants.solution_function_name_snake_case(),
                name: Constants.solution_function_name_snake_case(),
                params: %{
                  expected: "get_name",
                  actual: "getName"
                }
              }}
           ]
  end
end
