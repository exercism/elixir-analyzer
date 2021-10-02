defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.BooleanFunctionsTest do
  use ExUnit.Case
  alias ElixirAnalyzer.Comment
  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.ExerciseTest.CommonChecks.BooleanFunctions

  test "returns empty list if all names are correct" do
    code =
      quote do
        defmodule User do
          def active?(user), do: user.active
          defp registered?(user), do: true
          defguard is_user when true
          defguardp is_registered when true
          defmacro is_user(user), do: true
          defmacrop is_active(user), do: true
          defmacro admin?(user), do: user.admin
          defmacrop german?(user), do: user.country == "Germany"
        end
      end

    assert BooleanFunctions.run(code) == []
  end

  test "variables don't trigger comments" do
    code =
      quote do
        defmodule User do
          def register(user) do
            active? = true
            is_user = true
            is_active_user? = false
          end
        end
      end

    assert BooleanFunctions.run(code) == []
  end

  def assert_result(code, expected, actual) do
    assert BooleanFunctions.run(code) == [
             {:fail,
              %Comment{
                type: :actionable,
                comment: Constants.solution_boolean_functions(),
                name: Constants.solution_boolean_functions(),
                params: %{
                  expected: expected,
                  actual: actual
                }
              }}
           ]
  end

  test "returns an actionable comment with params" do
    code =
      quote do
        defmodule User do
          def is_active_user?(user), do: user.active
        end
      end

    assert_result(code, "def active_user?", "def is_active_user?")
  end

  test "is_active_user? also works for defp, defmacro, defmacrop, defguard, and defguardp" do
    code =
      quote do
        defmodule User do
          defp is_active_user?(user), do: true
        end
      end

    assert_result(code, "defp active_user?", "defp is_active_user?")

    code =
      quote do
        defmodule User do
          defmacro is_active_user?(user), do: true
        end
      end

    assert_result(
      code,
      "defmacro is_active_user or defmacro active_user?",
      "defmacro is_active_user?"
    )

    code =
      quote do
        defmodule User do
          defmacrop is_active_user?(user), do: true
        end
      end

    assert_result(
      code,
      "defmacrop is_active_user or defmacrop active_user?",
      "defmacrop is_active_user?"
    )

    code =
      quote do
        defmodule User do
          defguard(is_active_user?(user), do: true)
        end
      end

    assert_result(code, "defguard is_active_user", "defguard is_active_user?")

    code =
      quote do
        defmodule User do
          defguardp(is_active_user?(user), do: true)
        end
      end

    assert_result(code, "defguardp is_active_user", "defguardp is_active_user?")
  end

  test "is_active_user get comment for def, defp" do
    code =
      quote do
        defmodule User do
          def is_active_user(user), do: true
        end
      end

    assert_result(code, "def active_user?", "def is_active_user")

    code =
      quote do
        defmodule User do
          defp is_active_user(user), do: true
        end
      end

    assert_result(code, "defp active_user?", "defp is_active_user")
  end

  test "active_user? get comment for defguard, defguardp" do
    code =
      quote do
        defmodule User do
          defguard(active_user?(user), do: true)
        end
      end

    assert_result(code, "defguard is_active_user", "defguard active_user?")

    code =
      quote do
        defmodule User do
          defguardp(active_user?(user), do: true)
        end
      end

    assert_result(code, "defguardp is_active_user", "defguardp active_user?")
  end

  test "only reports the first wrong name" do
    code =
      quote do
        defmodule User do
          def is_active_user?(user), do: true
          defp is_active_user?(user), do: true
        end
      end

    assert_result(code, "def active_user?", "def is_active_user?")
  end
end
