defmodule ElixirAnalyzer.ExerciseTest.TwoFer do
  @moduledoc false

  alias ElixirAnalyzer.Constants

  use ElixirAnalyzer.ExerciseTest

  # these are all the tests need to pass for approval if no
  # failing tests that trigger a disapproval, defaults to []
  # if unspecified.
  @tests_needed_to_approve [
    "has default parameter",
    "has guard",
    "uses string interpolation",
  ]

  # has type specification
  feature "has spec" do
    # status :skip
    message  Constants.solution_use_specification
    severity :info
    match    :all

    form do
      @spec two_fer(String.t()) :: String.t()
    end
  end

  # has function header with default parameter
  feature "has default parameter" do
    # status :skip
    message  Constants.two_fer_use_default_parameter
    severity :disapprove
    match    :any

    # function header
    form do
      def two_fer(_ignore \\ "you")
    end

    # function with do block
    form do
      def two_fer(_ignore \\ "you") when _ignore do
        _ignore
      end
    end

    # function one-liner
    form do
      def two_fer(_ignore \\ "you") when _ignore, do: _ignore
    end
  end

  # function clauses use guards
  feature "has guard" do
    # status :skip
    message  Constants.two_fer_use_guards
    severity :disapprove
    match    :any

    form do
      def two_fer(_ignore) when is_binary(_ignore), do: _ignore
    end

    form do
      def two_fer(_ignore) do
        case _ignore do
          _ignore when is_binary(_ignore) -> _ignore
          _ -> _ignore
        end
      end
    end
  end

  # string interpolation used
  feature "uses string interpolation" do
    # status :skip
    message  Constants.two_fer_use_string_interpolation
    severity :disapprove
    match    :any

    form do
      "One for #{name}, one for me"
    end
  end

  feature "raises function clause error" do
    # status :skip
    message  Constants.solution_raise_fn_clause_error
    severity :info
    match    :none

    form do
      raise FunctionClauseError
    end
  end

  feature "first level @moduledoc recomended" do
    # status :skip
    message  Constants.solution_use_moduledoc
    severity :info
    match    :all
    depth    1

    form do
      @moduledoc _ignore
    end
  end
end
