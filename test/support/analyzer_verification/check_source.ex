defmodule ElixirAnalyzer.Support.AnalyzerVerification.CheckSource do
  @moduledoc """
  This is an exercise analyzer extension module to test the check_soucre macro
  """

  use ElixirAnalyzer.ExerciseTest

  check_source "always true" do
    type :actionable
    comment "always return true"

    check(_source) do
      true
    end
  end

  check_source "always false" do
    type :actionable
    comment "always return false"

    check(_source) do
      false
    end
  end

  check_source "finds integer literal" do
    type :actionable
    comment "used integer literal from ?a to ?z"

    check(source) do
      integers = Enum.map(?a..?z, &to_string/1)

      not Enum.any?(integers, &String.contains?(source, &1))
    end
  end

  check_source "finds use of multiline strings" do
    type :actionable
    comment "didn't use multiline"

    check(source) do
      String.contains?(source, ["\"\"\"", "\'\'\'"])
    end
  end

  check_source "module is suitably long" do
    type :actionable
    comment "module is too short"

    check(source) do
      String.length(source) > 20
    end
  end

  check_source "module is well formatted" do
    type :actionable
    comment "module is not formatted"

    check(source) do
      String.trim(source) == Code.format_string!(source) |> Enum.join()
    end
  end
end
